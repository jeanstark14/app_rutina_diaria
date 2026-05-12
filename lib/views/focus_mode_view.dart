import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../services/theme_provider.dart';
import '../services/task_provider.dart';
import '../services/user_provider.dart';
import '../services/notification_service.dart';
import '../models/task_model.dart';
import '../widgets/music_controls_overlay.dart';

class FocusModeView extends StatefulWidget {
  final String missionTitle;
  final int initialMinutes;
  final Task? task;

  const FocusModeView({
    super.key,
    required this.missionTitle,
    required this.initialMinutes,
    this.task,
  });

  @override
  State<FocusModeView> createState() => _FocusModeViewState();
}

class _FocusModeViewState extends State<FocusModeView> {
  late int _secondsRemaining;
  Timer? _timer;
  bool _isRunning = false;
  late int _totalSeconds;
  final NotificationService _notificationService = NotificationService();
  late PageController _missionPageController;
  int _currentMissionIndex = 0;
  List<Task> _availableMissions = [];
  Task? _selectedTask;

  @override
  void initState() {
    super.initState();
    _selectedTask = widget.task;
    _secondsRemaining = widget.initialMinutes * 60;
    _totalSeconds = widget.initialMinutes * 60;
    _missionPageController =
        PageController(viewportFraction: 0.85, initialPage: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMissions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _missionPageController.dispose();
    super.dispose();
  }

  void _initializeMissions() {
    if (!mounted) return;

    final taskProvider = context.read<TaskProvider>();
    final missions = taskProvider.missionsWithTimer;

    if (missions.isNotEmpty) {
      setState(() {
        _availableMissions = missions;
        
        // Si ya tenemos una tarea seleccionada (desde el widget), buscamos su índice
        if (_selectedTask != null) {
          final index = missions.indexWhere((m) => m.id == _selectedTask!.id);
          if (index != -1) {
            _currentMissionIndex = index;
            // Usamos jumpToPage para sincronizar el controlador sin disparar animaciones ruidosas
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_missionPageController.hasClients) {
                _missionPageController.jumpToPage(index);
              }
            });
          }
        } else {
          // Si no hay tarea previa, seleccionamos la primera
          _selectedTask = _availableMissions[0];
          _secondsRemaining = (_selectedTask?.duration?.inMinutes ?? 30) * 60;
          _totalSeconds = _secondsRemaining;
        }
      });
    }
  }

  void _startTimer() async {
    if (_isRunning) return;
    _timer?.cancel();

    final task = _selectedTask;
    if (task == null) return;

    setState(() => _isRunning = true);

    try {
      final durationMinutes = task.duration?.inMinutes ?? 30;
      await _notificationService.createSystemTimer(
        durationSeconds: durationMinutes * 60,
        title: task.title,
      );
    } catch (e) {
      debugPrint('Error al crear temporizador: $e');
    }

    final startTime = DateTime.now();
    final initialSeconds = _secondsRemaining;

    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = DateTime.now().difference(startTime).inSeconds;
      final newRemaining = initialSeconds - elapsed;

      if (newRemaining <= 0) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _isRunning = false;
        });
        _onTimerComplete();
      } else if (newRemaining != _secondsRemaining) {
        setState(() => _secondsRemaining = newRemaining);
      }
    });
  }

  void _onTimerComplete() async {
    _timer?.cancel();

    if (_selectedTask != null) {
      try {
        final taskProvider = context.read<TaskProvider>();
        final userProvider = context.read<UserProvider>();

        final xp = await taskProvider.completeTaskWithSubtasks(_selectedTask!);
        await userProvider.addXp(xp);

        _showSuccessDialog(xp);
      } catch (e) {
        debugPrint('Error al completar tarea: $e');
        _showSuccessDialog(0);
      }
    } else {
      _showSuccessDialog(0);
    }
  }

  void _pauseTimer() async {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer(int minutes) async {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = minutes * 60;
      _totalSeconds = minutes * 60;
      _isRunning = false;
    });
  }

  void _onMissionPageChanged(int index) {
    if (_availableMissions.isEmpty || _currentMissionIndex == index) return;
    
    setState(() {
      _currentMissionIndex = index;
      _selectedTask = _availableMissions[index];
      _secondsRemaining = (_selectedTask?.duration?.inMinutes ?? 30) * 60;
      _totalSeconds = _secondsRemaining;
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _showSuccessDialog(int xpGained) {
    final message = xpGained > 0
        ? 'Mision completada con todas sus subtareas!\nHas ganado $xpGained XP por tu excelente desempeno.'
        : 'Concentracion absoluta mantenida. Sigue asi.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(xpGained > 0 ? 'MISIÓN COMPLETADA!' : 'MISIÓN CUMPLIDA',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: const Text('ENTENDIDO'),
            ),
          )
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = themeProvider.primaryColor;
    final progress =
        _totalSeconds == 0 ? 0.0 : _secondsRemaining / _totalSeconds;

    final selectedTask = _selectedTask ??
        (widget.task ??
            (_availableMissions.isNotEmpty ? _availableMissions[0] : null));

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('PROTOCOLO DE COMBATE',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          if (_availableMissions.isEmpty)
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.timer_off_outlined,
                            size: 80,
                            color: primaryColor.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'SIN MISIONES ACTIVAS',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.textBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No tienes tareas con temporizador configuradas para hoy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppTheme.textGrey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'VOLVER AL PANEL',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              if (_availableMissions.length > 1)
                                SizedBox(
                                  height: 100,
                                  child: PageView.builder(
                                    controller: _missionPageController,
                                    onPageChanged: _onMissionPageChanged,
                                    itemCount: _availableMissions.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final mission = _availableMissions[index];
                                      final isSelected =
                                          _currentMissionIndex == index;
                                      final taskColor = Color(mission.color);
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isDark
                                                  ? AppTheme.darkSurface
                                                  : Colors.white)
                                              : (isDark
                                                  ? Colors.white10
                                                  : Colors.grey.shade100),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? taskColor
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                      color:
                                                          taskColor.withValues(
                                                              alpha: 0.3),
                                                      blurRadius: 12)
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.radar,
                                                color: taskColor, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    mission.title,
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white
                                                          : AppTheme.textBlack,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${mission.duration?.inMinutes ?? 30} min',
                                                    style: TextStyle(
                                                      color: isDark
                                                          ? Colors.white60
                                                          : AppTheme.textGrey,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: primaryColor.withValues(
                                            alpha: 0.3)),
                                  ),
                                  child: Text(
                                    'MISIÓN: ${selectedTask?.title.toUpperCase() ?? 'NINGUNA'}',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 12,
                                      backgroundColor: isDark
                                          ? Colors.white10
                                          : Colors.black12,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          primaryColor),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    height: 220,
                                    child: CircularProgressIndicator(
                                      value: 1,
                                      strokeWidth: 1,
                                      backgroundColor: Colors.transparent,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          primaryColor.withValues(alpha: 0.2)),
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatTime(_secondsRemaining),
                                        style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'monospace'),
                                      ),
                                      Text(
                                        _isRunning
                                            ? 'COMBATE ACTIVO'
                                            : 'EN ESPERA',
                                        style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildTimeOption('25m', 25, primaryColor),
                                  const SizedBox(width: 16),
                                  _buildTimeOption('50m', 50, primaryColor),
                                  const SizedBox(width: 16),
                                  _buildTimeOption(
                                      '${selectedTask?.duration?.inMinutes ?? 30}m',
                                      selectedTask?.duration?.inMinutes ?? 30,
                                      primaryColor),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildActionButton(
                                    icon: _isRunning
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    label: _isRunning ? 'PAUSAR' : 'INICIAR',
                                    color: _isRunning
                                        ? Colors.orange
                                        : Colors.green,
                                    onTap:
                                        _isRunning ? _pauseTimer : _startTimer,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.stop,
                                    label: 'ABORTAR',
                                    color: Colors.red,
                                    onTap: () async {
                                      if (context.mounted)
                                        Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const MusicControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String label, int mins, Color color) {
    bool isSelected = _totalSeconds == mins * 60;
    return GestureDetector(
      onTap: () => _resetTimer(mins),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
