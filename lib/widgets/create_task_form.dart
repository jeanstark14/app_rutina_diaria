import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/task_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class CreateTaskForm extends StatefulWidget {
  final Task? taskToEdit;
  const CreateTaskForm({super.key, this.taskToEdit});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  final _manualDurationController = TextEditingController();

  late TimeOfDay _selectedTime;
  late int _selectedDuration;
  late String _selectedRepeat;
  List<int> _customDays = [];

  late int _selectedColor;
  late TaskPriority _selectedPriority;
  bool _syncToClock = false;

  final List<String> _repeatOptions = [
    'Una vez',
    'Diario',
    'Lun-Vie',
    'Semanal',
    'Personalizado'
  ];
  final List<int> _colorPalette = [
    0xFF2D62ED,
    0xFF1565C0,
    0xFF0D47A1,
    0xFFE53935,
    0xFFD32F2F,
    0xFFC62828,
    0xFFFF9800,
    0xFFF57C00,
    0xFFEF6C00,
    0xFF4CAF50,
    0xFF388E3C,
    0xFF2E7D32,
    0xFF9C27B0,
    0xFF7B1FA2,
    0xFF6A1B9A,
    0xFF00BCD4,
    0xFF0097A7,
    0xFF00838F,
    0xFF795548,
    0xFF5D4037,
    0xFF4E342E,
    0xFFE91E63,
    0xFFC2185B,
    0xFFAD1457,
    0xFFFFEB3B,
    0xFFFBC02D,
    0xFFF9A825,
    0xFF607D8B,
    0xFF455A64,
    0xFF37474F,
    0xFF3F51B5,
    0xFF303F9F,
    0xFF283593,
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final taskProvider = context.read<TaskProvider>();
    debugPrint('=== FORM DID CHANGE DEPENDENCIES ===');
    debugPrint('Fecha seleccionada en provider: ${taskProvider.selectedDate}');
    debugPrint(
        'Día/Mes/Año: ${taskProvider.selectedDate.day}/${taskProvider.selectedDate.month}/${taskProvider.selectedDate.year}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _manualDurationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _notesController = TextEditingController(text: task?.notes ?? '');
    _selectedTime = task != null
        ? TimeOfDay.fromDateTime(task.startTime)
        : const TimeOfDay(hour: 8, minute: 0);
    _selectedDuration = task?.duration?.inMinutes ?? 30;
    _manualDurationController.text = _selectedDuration.toString();
    _customDays = task?.repeatDays ?? [];

    _selectedColor = task?.color ?? 0xFF2D62ED;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _syncToClock = task?.syncEnabled ?? false;

    if (task == null || task.repeatDays.isEmpty) {
      _selectedRepeat = 'Una vez';
    } else if (task.repeatDays.length == 7) {
      _selectedRepeat = 'Diario';
    } else if (task.repeatDays.length == 5 &&
        !task.repeatDays.contains(6) &&
        !task.repeatDays.contains(7)) {
      _selectedRepeat = 'Lun-Vie';
    } else if (task.repeatDays.length == 1) {
      _selectedRepeat = 'Semanal';
    } else {
      _selectedRepeat = 'Personalizado';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final selectedDate = taskProvider.selectedDate;

    debugPrint('=== SUBMIT DEBUG ===');
    debugPrint('selectedDate del provider: $selectedDate');
    debugPrint(
        'selectedDate día/mes/año: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}');
    debugPrint(
        '_selectedTime hora:minuto: ${_selectedTime.hour}:${_selectedTime.minute}');

    final startTime = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    debugPrint('startTime creado: $startTime');
    debugPrint(
        'startTime día/mes/año: ${startTime.day}/${startTime.month}/${startTime.year}');

    if (widget.taskToEdit == null) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        startTime: startTime,
        duration: Duration(minutes: _selectedDuration),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        repeatDays: _getRepeatDays(_selectedRepeat, startTime),
        completedDates: const [],
        color: _selectedColor,
        priority: _selectedPriority,
        syncEnabled: _syncToClock,
      );

      debugPrint(
          'Creando nueva tarea: "${newTask.title}" para fecha ${newTask.startTime}');
      await taskProvider.addTask(newTask, syncToClock: _syncToClock);
    } else {
      final updatedTask = widget.taskToEdit!.copyWith(
        syncEnabled: _syncToClock,
        title: _titleController.text,
        startTime: startTime,
        duration: Duration(minutes: _selectedDuration),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        repeatDays: _getRepeatDays(_selectedRepeat, startTime),
        color: _selectedColor,
        priority: _selectedPriority,
      );
      await taskProvider.updateTask(updatedTask);
    }

    final statusMsg = taskProvider.lastStatusMessage;
    taskProvider.clearStatusMessage();

    if (context.mounted) {
      Navigator.of(context).pop(true);

      if (statusMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(statusMsg),
            backgroundColor: themeProvider.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  List<int> _getRepeatDays(String option, DateTime startTime) {
    switch (option) {
      case 'Diario':
        return [1, 2, 3, 4, 5, 6, 7];
      case 'Lun-Vie':
        return [1, 2, 3, 4, 5];
      case 'Semanal':
        return [startTime.weekday];
      case 'Personalizado':
        return _customDays;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;
    final isEditing = widget.taskToEdit != null;

    return Container(
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
          color: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Abortar',
                          style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : AppTheme.textGrey))),
                  Text(isEditing ? 'Modificar Misión' : 'Nueva Misión',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppTheme.textBlack)),
                  const SizedBox(width: 60),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textBlack),
                decoration: InputDecoration(
                    hintText: 'Objetivo de la misión...',
                    hintStyle: TextStyle(
                        color: isDark ? Colors.white24 : Colors.grey.shade400),
                    border: InputBorder.none),
                validator: (val) => val == null || val.isEmpty ? '' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _buildPillPicker(
                          'Inicio Táctico',
                          _selectedTime.format(context),
                          Icons.access_time_filled, () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryColor,
                              surface: Colors.white,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) setState(() => _selectedTime = picked);
                  }, isDark, primaryColor)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildPillPicker(
                          'Duración',
                          '$_selectedDuration MIN',
                          Icons.timelapse,
                          () => _showDurationPicker(primaryColor),
                          isDark,
                          primaryColor)),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                  'Nivel de Prioridad y Camuflaje (Color)', isDark),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<TaskPriority>(
                      value: _selectedPriority,
                      underline: const SizedBox(),
                      isDense: true,
                      items: TaskPriority.values
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p == TaskPriority.high
                                      ? 'ALTA'
                                      : p == TaskPriority.medium
                                          ? 'MEDIA'
                                          : 'BAJA',
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppTheme.textBlack),
                                ),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedPriority = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _colorPalette.length,
                  itemBuilder: (context, index) {
                    final color = _colorPalette[index];
                    final isSelected = _selectedColor == color;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : (isDark
                                  ? Border.all(color: Colors.white24, width: 1)
                                  : null),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                      color:
                                          Color(color).withValues(alpha: 0.6),
                                      blurRadius: 8)
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Protocolo de Repetición', isDark),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                    children: _repeatOptions
                        .map((opt) =>
                            _buildRepeatButton(opt, isDark, primaryColor))
                        .toList()),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                  'Sincronización con Reloj del Sistema', isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.access_alarm, color: primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sincronizar con reloj nativo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textBlack,
                            ),
                          ),
                          Text(
                            'Crear alarma automáticamente en la app de reloj',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.white54 : AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _syncToClock,
                      onChanged: (value) =>
                          setState(() => _syncToClock = value),
                      activeColor: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Información de Inteligencia (Notas)', isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textBlack),
                  decoration: InputDecoration(
                      hintText: 'Detalles confidenciales...',
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : AppTheme.textGrey),
                      border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            isEditing
                                ? 'ACTUALIZAR MISIÓN'
                                : 'CONFIRMAR MISIÓN',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Icon(Icons.rocket_launch)
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDurationPicker(Color primaryColor) {
    final List<int> durations = [15, 30, 45, 60, 90];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tiempo Estimado de Misión',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: durations
                    .map((d) =>
                        _buildDurationChip(d, setModalState, primaryColor))
                    .toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _manualDurationController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                    hintText: 'Minutos manuales',
                    filled: true,
                    fillColor: primaryColor.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none)),
                onChanged: (val) {
                  final minutes = int.tryParse(val);
                  if (minutes != null) {
                    setModalState(() => _selectedDuration = minutes);
                    setState(() => _selectedDuration = minutes);
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25))),
                      child: const Text('LISTO'))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(
      int d, StateSetter setModalState, Color primaryColor) {
    return ChoiceChip(
      label: Text('$d min'),
      selected: _selectedDuration == d,
      onSelected: (val) {
        setModalState(() => _selectedDuration = d);
        setState(() => _selectedDuration = d);
        _manualDurationController.text = d.toString();
      },
      selectedColor: primaryColor,
      labelStyle: TextStyle(
          color: _selectedDuration == d ? Colors.white : Colors.black),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(title.toUpperCase(),
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppTheme.textGrey,
            fontSize: 11,
            letterSpacing: 1.2));
  }

  Widget _buildPillPicker(String label, String value, IconData icon,
      VoidCallback onTap, bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(label, isDark),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(35)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(value,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppTheme.textBlack),
                        overflow: TextOverflow.ellipsis)),
                Icon(icon, color: primaryColor, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatButton(String label, bool isDark, Color primaryColor) {
    final isSelected = _selectedRepeat == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          if (label == 'Personalizado')
            _showCustomDaysPicker(primaryColor);
          else
            setState(() => _selectedRepeat = label);
        },
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        selectedColor: primaryColor,
        labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : AppTheme.textBlack),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        showCheckmark: false,
      ),
    );
  }

  void _showCustomDaysPicker(Color primaryColor) {
    final days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Días de Misión'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(7, (index) {
              final dayNum = index + 1;
              final isSelected = _customDays.contains(dayNum);
              return FilterChip(
                label: Text(days[index]),
                selected: isSelected,
                onSelected: (val) {
                  setDialogState(() {
                    if (val)
                      _customDays.add(dayNum);
                    else
                      _customDays.remove(dayNum);
                    _customDays.sort();
                  });
                  setState(() => _selectedRepeat = 'Personalizado');
                },
                selectedColor: primaryColor,
                labelStyle:
                    TextStyle(color: isSelected ? Colors.white : Colors.black),
              );
            }),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CONFIRMAR'))
          ],
        ),
      ),
    );
  }
}
