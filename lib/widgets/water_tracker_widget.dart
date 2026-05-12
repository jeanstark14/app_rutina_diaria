import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/water_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class WaterTrackerWidget extends StatelessWidget {
  const WaterTrackerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final waterProvider = context.watch<WaterProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.water_drop,
                    color: primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PROTOCOLO DE HIDRATACIÓN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              if (waterProvider.currentStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${waterProvider.currentStreak}D',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${waterProvider.todayIntake}/${waterProvider.dailyGoal} vasos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textBlack,
                ),
              ),
              Text(
                '${(waterProvider.progressPercent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: waterProvider.isGoalCompleted ? Colors.green : primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: waterProvider.progressPercent,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                waterProvider.isGoalCompleted ? Colors.green : primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Glasses row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(waterProvider.dailyGoal, (index) {
              final isFilled = index < waterProvider.todayIntake;
              return _WaterGlass(
                isFilled: isFilled,
                index: index,
                primaryColor: primaryColor,
                onTap: () => _handleGlassTap(context, waterProvider, index),
              );
            }),
          ),
          
          // Goal completed message
          if (waterProvider.isGoalCompleted) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¡META DE HIDRATACIÓN COMPLETADA!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleGlassTap(BuildContext context, WaterProvider provider, int index) {
    if (index < provider.todayIntake) {
      // Quitar este vaso y todos los siguientes
      provider.removeGlass();
    } else if (index == provider.todayIntake) {
      // Agregar el siguiente vaso
      provider.addGlass();
    }
  }
}

class _WaterGlass extends StatelessWidget {
  final bool isFilled;
  final int index;
  final Color primaryColor;
  final VoidCallback onTap;

  const _WaterGlass({
    required this.isFilled,
    required this.index,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 44,
        decoration: BoxDecoration(
          color: isFilled ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFilled ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isFilled
                ? Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 20,
                    key: ValueKey('filled_$index'),
                  )
                : Icon(
                    Icons.add,
                    color: Colors.grey.shade400,
                    size: 16,
                    key: ValueKey('empty_$index'),
                  ),
          ),
        ),
      ),
    );
  }
}
