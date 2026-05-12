import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/task_provider.dart';
import '../services/user_provider.dart';
import '../services/theme_provider.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../widgets/create_task_form.dart';
import '../widgets/task_detail_modal.dart';
import 'master_schedule_view.dart';
import 'calendar_view.dart';
import 'config_view.dart';
import 'focus_mode_view.dart';
import 'mission_complete_view.dart';
import 'water_tracker_view.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
      _checkCelebration();
      _showWelcomeVerseIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar celebración cuando cambia el estado del provider
    // (ej: después de completar una tarea)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkCelebration();
    });
  }

  Future<void> _checkPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final permissionsShown = prefs.getBool('permissions_shown') ?? false;

    if (!permissionsShown) {
      await prefs.setBool('permissions_shown', true);
    }
  }

  void _showWelcomeVerseIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastShown = prefs.getString('welcome_verse_date') ?? '';

    if (lastShown != today) {
      prefs.setString('welcome_verse_date', today);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showWelcomeVerse();
      });
    }
  }

  void _showWelcomeVerse() {
    final themeProvider = context.read<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;

    final verses = [
      {
        'text': '"Todo lo puedo en Cristo que me fortalece."',
        'ref': 'Filipenses 4:13'
      },
      {
        'text': '"El Señor es mi pastor; nada me faltará."',
        'ref': 'Salmo 23:1'
      },
      {
        'text':
            '"Mira que te mando que te esfuerces y seas valiente; no temas ni desmayes, porque Jehová tu Dios estará contigo en dondequiera que vayas."',
        'ref': 'Josué 1:9'
      },
      {
        'text': '"Encomienda al Señor tu camino, confía en Él y Él hará."',
        'ref': 'Salmo 37:5'
      },
      {
        'text': '"No temas, porque yo estoy contigo; no desmayes."',
        'ref': 'Isaías 41:10'
      },
      {
        'text': '"Sean fuertes y valientes. No tengan miedo."',
        'ref': 'Deuteronomio 31:6'
      },
      {
        'text': '"Jehová es mi luz y mi salvación; ¿de quién temeré?"',
        'ref': 'Salmo 27:1'
      },
      {
        'text': '"Echa sobre Jehovah toda tu ansiedad, porque Él cuida de ti."',
        'ref': '1 Pedro 5:7'
      },
      {
        'text': '"Jehovah mora en medio de ti. ¡Él es poderoso!"',
        'ref': 'Sofonías 3:17'
      },
      {
        'text':
            '"Levanten sus ojos hacia los montes, de donde vendrá su auxílio."',
        'ref': 'Salmo 121:1-2'
      },
      {
        'text': '"Bienaventurados los que tienen hambre y sed de justicia."',
        'ref': 'Mateo 5:6'
      },
      {
        'text': '"Yo soy el camino, y la verdad, y la vida."',
        'ref': 'Juan 14:6'
      },
      {
        'text': '"No se angustien por nada, sino en todo oren."',
        'ref': 'Filipenses 4:6'
      },
      {
        'text': '"Jehovah da la fuerza al que está cansado."',
        'ref': 'Isaías 40:29'
      },
      {
        'text': '"Venid a mí todos los que están cansados y agobiados."',
        'ref': 'Mateo 11:28'
      },
      {
        'text': '"Donde no hay guía, el pueblo cae; en mucha hay salud."',
        'ref': 'Proverbios 11:14'
      },
      {'text': '"Clama a mí, y yo te responderé."', 'ref': 'Jeremías 33:3'},
    ];

    final randomIndex = DateTime.now().millisecondsSinceEpoch % verses.length;
    final verse = verses[randomIndex];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.auto_awesome, color: primaryColor, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('MENSAJE DEL DÍA',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 2,
                    color: Colors.black)),
            const SizedBox(height: 16),
            Text(verse['text']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87)),
            const SizedBox(height: 8),
            Text(verse['ref']!,
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                child: const Text('ACEPTAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkCelebration() {
    if (!mounted) return;
    final taskProvider = context.read<TaskProvider>();
    debugPrint('=== CHECK CELEBRATION ===');
    debugPrint('showCelebration: ${taskProvider.showCelebration}');
    debugPrint('Tareas totales: ${taskProvider.tasks.length}');
    debugPrint(
        'Tareas completadas: ${taskProvider.tasks.where((t) => t.isCompletedForDate(taskProvider.selectedDate)).length}');

    if (taskProvider.showCelebration) {
      debugPrint('Mostrando pantalla de celebración!');
      _showPrimeCelebration(context);
      taskProvider.resetCelebration();
    }
  }

  void _showPrimeCelebration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MissionCompleteView(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tasks = taskProvider.tasks;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeaderSection(),
            const _TacticalHUD(),
            const _ProgressSection(),
            const _CalendarStrip(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      tasks.isEmpty
                          ? 'Sin misiones tácticas'
                          : 'Misiones del Día',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isDark ? Colors.white : AppTheme.textBlack)),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: primaryColor),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CalendarView())),
                    tooltip: 'Agenda de Operaciones',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        try {
                          return _TaskItem(task: tasks[index]);
                        } catch (e) {
                          debugPrint('Error renderizando tarea $index: $e');
                          return const SizedBox.shrink();
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final userProvider = context.watch<UserProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final primaryColor = themeProvider.primaryColor;
    final accentColor = themeProvider.accentColor;
    final nameGradientColors = [primaryColor, accentColor];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.rank.toUpperCase(),
                  style: GoogleFonts.outfit(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Agente',
                  style: GoogleFonts.outfit(
                    color: isDark ? Colors.white : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: nameGradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: Text(
                    userProvider.name.split(' ')[0],
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: userProvider.levelProgress,
                          minHeight: 4,
                          backgroundColor:
                              isDark ? Colors.white10 : Colors.black12,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'LVL ${userProvider.level}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: Icon(Icons.format_list_bulleted, color: primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MasterScheduleView()),
            ),
            tooltip: 'Lista Maestra',
          ),
          IconButton(
            icon: Icon(Icons.water_drop, color: primaryColor),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WaterTrackerView()),
            ),
            tooltip: 'Hidratación',
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ConfigView()),
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  backgroundImage: userProvider.profileImage != null
                      ? FileImage(userProvider.profileImage!)
                      : null,
                  child: userProvider.profileImage == null
                      ? Text(
                          userProvider.name.substring(0, 1).toUpperCase(),
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                if (taskProvider.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.orange, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.bolt, color: Colors.white, size: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TacticalHUD extends StatefulWidget {
  const _TacticalHUD();

  @override
  State<_TacticalHUD> createState() => _TacticalHUDState();
}

class _TacticalHUDState extends State<_TacticalHUD> {
  final PageController _pageController =
      PageController(viewportFraction: 0.9, initialPage: 0);
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final activeMissions = taskProvider.missionsWithTimer;
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    if (activeMissions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'MISIONES ACTIVAS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primaryColor,
              letterSpacing: 1,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: activeMissions.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final mission = activeMissions[index];
              final isSelected = _currentIndex == index;
              final taskColor = Color(mission.color);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? taskColor
                        : primaryColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: taskColor.withValues(alpha: 0.2),
                              blurRadius: 10)
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: taskColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.timer, color: taskColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mission.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppTheme.textBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mission.duration?.inMinutes ?? 30} min • ${DateFormat('HH:mm').format(mission.startTime)}',
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FocusModeView(
                            missionTitle: mission.title,
                            initialMinutes: mission.duration?.inMinutes ?? 30,
                            task: mission,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 0),
                        minimumSize: const Size(50, 28),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('COMBATE',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (activeMissions.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                activeMissions.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == _currentIndex ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final tasks = taskProvider.tasks;
    final completedCount = tasks
        .where((t) => t.isCompletedForDate(taskProvider.selectedDate))
        .length;
    final totalCount = tasks.length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
    final primaryColor = themeProvider.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('POTENCIAL HEROICO',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: isDark ? Colors.white70 : AppTheme.textGrey,
                      letterSpacing: 1)),
              Text('$completedCount/$totalCount MISIONES',
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor))),
        ],
      ),
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip();

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;
    final now = DateTime.now();

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = now.add(Duration(days: index - 3));
          final isSelected = taskProvider.selectedDate.day == date.day &&
              taskProvider.selectedDate.month == date.month &&
              taskProvider.selectedDate.year == date.year;
          final dayName = DateFormat('E', 'es_ES').format(date).toUpperCase();
          final isToday = date.day == now.day &&
              date.month == now.month &&
              date.year == now.year;

          return GestureDetector(
            onTap: () => taskProvider.setSelectedDate(date),
            child: Container(
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? AppTheme.darkSurface : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ]
                    : [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5)
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isToday ? 'ACTUAL' : dayName,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white60 : AppTheme.textGrey))),
                  const SizedBox(height: 4),
                  Text(date.day.toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white : AppTheme.textBlack))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TaskItem extends StatefulWidget {
  final Task task;
  const _TaskItem({required this.task});

  @override
  State<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<_TaskItem> {
  bool _isExpanded = false;

  Task get task => widget.task;

  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        builder: (context) => CreateTaskForm(taskToEdit: task));
  }

  void _showTaskDetailModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TaskDetailModal(task: task),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final userProvider = context.watch<UserProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final isCompleted = task.isCompletedForDate(taskProvider.selectedDate);
    final taskColor = Color(task.color);
    final hasSubtasks = task.subtasks.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(DateFormat('HH:mm').format(task.startTime),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isCompleted
                                ? (isDark
                                    ? Colors.white30
                                    : Colors.grey.shade400)
                                : (isDark ? Colors.white : AppTheme.textBlack),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationThickness: 2.0,
                            decorationColor: isDark
                                ? Colors.white30
                                : Colors.grey.shade400)),
                    Text(DateFormat('a').format(task.startTime),
                        style: TextStyle(
                            fontSize: 10,
                            color: isCompleted
                                ? (isDark
                                    ? Colors.white30
                                    : Colors.grey.shade400)
                                : (isDark
                                    ? Colors.white38
                                    : AppTheme.textGrey))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showEditModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                      border: !isCompleted
                          ? Border(left: BorderSide(color: taskColor, width: 6))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: taskColor.withOpacity(0.1),
                              shape: BoxShape.circle),
                          child: Icon(_getIconForTask(task.title),
                              color: taskColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (task.priority == TaskPriority.high)
                                    Container(
                                        margin: const EdgeInsets.only(right: 6),
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle)),
                                  Expanded(
                                    child: Text(task.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: isCompleted
                                                ? (isDark
                                                    ? Colors.white30
                                                    : Colors.grey.shade400)
                                                : (isDark
                                                    ? Colors.white
                                                    : AppTheme.textBlack),
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            decorationThickness: 2.0,
                                            decorationColor: isDark
                                                ? Colors.white30
                                                : Colors.grey.shade400)),
                                  ),
                                ],
                              ),
                              Text(
                                  '${task.duration?.inMinutes ?? 30} min • Prioridad ${_getPriorityText(task.priority)}',
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : AppTheme.textGrey,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.open_in_full,
                              size: 18, color: taskColor.withOpacity(0.6)),
                          onPressed: () => _showTaskDetailModal(context),
                          tooltip: 'Ver detalles',
                        ),
                        IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 20, color: Colors.red.withOpacity(0.5)),
                            onPressed: () =>
                                _confirmDelete(context, taskProvider)),
                        GestureDetector(
                          onTap: () async {
                            final xp =
                                await taskProvider.toggleTaskStatus(task);
                            userProvider.addXp(xp);
                          },
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: isCompleted
                                        ? taskColor
                                        : (isDark
                                            ? Colors.white24
                                            : Colors.grey.shade300),
                                    width: 2),
                                borderRadius: BorderRadius.circular(8),
                                color: isCompleted
                                    ? taskColor
                                    : Colors.transparent),
                            child: isCompleted
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 18)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Sección de subtareas expandible
          if (hasSubtasks) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Row(
                children: [
                  const SizedBox(width: 68),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isExpanded
                        ? 'Ocultar subtareas (${task.subtaskProgressPercent}%)'
                        : 'Ver ${task.subtasks.length} subtareas (${task.completedSubtasksCount}/${task.subtasks.length})',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 68),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.darkSurface.withOpacity(0.5)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.grey.shade200,
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: task.subtasks.length,
                        itemBuilder: (context, index) {
                          final subtask = task.subtasks[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final xp = await taskProvider.toggleSubtask(
                                        task.id, subtask.id);
                                    userProvider.addXp(xp);
                                    // Forzar actualización inmediata de la UI
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: subtask.isCompleted
                                            ? taskColor
                                            : (isDark
                                                ? Colors.white30
                                                : Colors.grey.shade400),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      color: subtask.isCompleted
                                          ? taskColor
                                          : Colors.transparent,
                                    ),
                                    child: subtask.isCompleted
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 14)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${index + 1}. ${subtask.title}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtask.isCompleted
                                          ? (isDark
                                              ? Colors.white38
                                              : Colors.grey.shade500)
                                          : (isDark
                                              ? Colors.white70
                                              : AppTheme.textBlack),
                                      decoration: subtask.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // Botón para completar tarea si todas las subtareas están hechas
              if (task.areAllSubtasksCompleted && !isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(width: 68),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final xp =
                              await taskProvider.completeTaskWithSubtasks(task);
                          userProvider.addXp(xp);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('¡Misión "${task.title}" completada!'),
                              backgroundColor: taskColor,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          // Forzar actualización inmediata de la UI
                          if (mounted) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: taskColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: taskColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: taskColor, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Completar misión',
                                style: TextStyle(
                                  color: taskColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  String _getPriorityText(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 'Nivel S';
      case TaskPriority.medium:
        return 'Nivel A';
      case TaskPriority.low:
        return 'Nivel B';
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, TaskProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Abortar misión?'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCELAR')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ABORTAR', style: TextStyle(color: Colors.red)))
        ],
      ),
    );
    if (confirmed == true) provider.deleteTask(task.id);
  }

  IconData _getIconForTask(String title) {
    title = title.toLowerCase();
    if (title.contains('desayuno') || title.contains('comida'))
      return Icons.restaurant;
    if (title.contains('gym') || title.contains('ejercicio')) return Icons.bolt;
    if (title.contains('trabajo')) return Icons.work;
    if (title.contains('reunión')) return Icons.hub;
    if (title.contains('descanso')) return Icons.bed;
    if (title.contains('película')) return Icons.movie;
    if (title.contains('tiempo libre')) return Icons.sports_esports;
    if (title.contains('lectura')) return Icons.menu_book;
    if (title.contains('estudio')) return Icons.menu_book;
    if (title.contains('cine')) return Icons.movie;
    if (title.contains('compra')) return Icons.shopping_cart;
    if (title.contains('limpieza')) return Icons.cleaning_services;
    if (title.contains('paseo')) return Icons.directions_walk;
    if (title.contains('meditar')) return Icons.menu_book_outlined;
    if (title.contains('Creacion de Contenido')) return Icons.video_call;
    return Icons.shield;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shield_outlined,
            size: 80,
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        const SizedBox(height: 16),
        Text('Sin misiones asignadas',
            style: TextStyle(
                color: AppTheme.textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text('"Como siempre, es un gran placer verlo trabajar."',
            style: TextStyle(
                color: AppTheme.textGrey.withOpacity(0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic)),
      ]),
    );
  }
}
