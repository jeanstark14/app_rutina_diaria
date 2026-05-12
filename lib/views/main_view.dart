import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/create_task_form.dart';
import 'agenda_view.dart';
import 'calendar_view.dart';
import 'stats_view.dart';
import 'config_view.dart';
import 'movie_calendar_view.dart';
import 'nutrition_center_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;

  final List<Widget> _views = [
    const AgendaView(),
    const CalendarView(),
    const NutritionCenterView(), // Nuevo: Nutrición
    const SizedBox.shrink(), // Placeholder para el botón central
    const MovieCalendarView(),
    StatsView(),
    const ConfigView(),
  ];

  void _onItemTapped(int index) {
    if (index == 3) {
      // Índice del botón central - mostrar modal
      _showAddTaskModal();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showAddTaskModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const CreateTaskForm(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _views,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Inicio',
                    isSelected: _currentIndex == 0,
                    primaryColor: primaryColor,
                    onTap: () => _onItemTapped(0),
                  ),
                ),
                // Calendario
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today,
                    label: 'Agenda',
                    isSelected: _currentIndex == 1,
                    primaryColor: primaryColor,
                    onTap: () => _onItemTapped(1),
                  ),
                ),
                // Nutrición (Nuevo)
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.restaurant_outlined,
                    activeIcon: Icons.restaurant,
                    label: 'Dieta',
                    isSelected: _currentIndex == 2,
                    primaryColor: primaryColor,
                    onTap: () => _onItemTapped(2),
                  ),
                ),
                // Botón Central de Agregar
                _buildCenterAddButton(primaryColor),
                // Películas
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.movie_outlined,
                    activeIcon: Icons.movie,
                    label: 'Películas',
                    isSelected: _currentIndex == 4,
                    primaryColor: primaryColor,
                    onTap: () => _onItemTapped(4),
                  ),
                ),
                // Estadísticas
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.insights_outlined,
                    activeIcon: Icons.insights,
                    label: 'Stats',
                    isSelected: _currentIndex == 5,
                    primaryColor: primaryColor,
                    onTap: () => _onItemTapped(5),
                  ),
                ),
                // Configuración
                Expanded(
                  child: _buildNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Config',
                    isSelected: _currentIndex == 6,
                    primaryColor: primaryColor,
                    onTap: () => _onItemTapped(6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(Color primaryColor) {
    return GestureDetector(
      onTap: () => _onItemTapped(3),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.rocket_launch,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
