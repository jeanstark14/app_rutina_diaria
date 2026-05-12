import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/water_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class WaterTrackerView extends StatelessWidget {
  const WaterTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final waterProvider = context.watch<WaterProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('PROTOCOLO DE HIDRATACIÓN',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header con racha
            _buildHeaderCard(waterProvider, isDark, primaryColor),
            const SizedBox(height: 32),

            // Contador principal
            _buildMainCounter(waterProvider, isDark, primaryColor),
            const SizedBox(height: 32),

            // Grid de vasos
            _buildGlassesGrid(waterProvider, isDark, primaryColor),
            const SizedBox(height: 32),

            // Botones de acción
            _buildActionButtons(waterProvider, isDark, primaryColor),
            const SizedBox(height: 32),

            // Información
            _buildInfoCard(waterProvider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
      WaterProvider water, bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'SUMINISTRO HÍDRICO',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (water.currentStreak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade300,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Racha: ${water.currentStreak} días',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainCounter(
      WaterProvider water, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${water.todayIntake}',
            style: TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              color: water.isGoalCompleted ? Colors.green : primaryColor,
            ),
          ),
          Text(
            'de ${water.dailyGoal} vasos',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white70 : AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: water.progressPercent,
              minHeight: 12,
              backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                water.isGoalCompleted ? Colors.green : primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(water.progressPercent * 100).toInt()}% completado',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white60 : AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassesGrid(
      WaterProvider water, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REGISTRO DE VASOS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppTheme.textGrey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(water.dailyGoal, (index) {
              final isFilled = index < water.todayIntake;
              return GestureDetector(
                onTap: () {
                  if (index < water.todayIntake) {
                    water.removeGlass();
                  } else if (index == water.todayIntake) {
                    water.addGlass();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isFilled ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isFilled
                          ? primaryColor
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
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
                              size: 24,
                              key: ValueKey('filled'),
                            )
                          : Icon(
                              Icons.add,
                              color: isDark
                                  ? Colors.white30
                                  : Colors.grey.shade400,
                              size: 20,
                              key: const ValueKey('empty'),
                            ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      WaterProvider water, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: water.isGoalCompleted ? null : () => water.addGlass(),
            icon: Icon(Icons.add),
            label: Text('AGREGAR VASO'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor:
                  isDark ? Colors.white10 : Colors.grey.shade300,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: water.todayIntake > 0 ? () => water.removeGlass() : null,
            icon: Icon(Icons.remove),
            label: Text('QUITAR VASO'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white70 : Colors.grey.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(WaterProvider water, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkSurface.withOpacity(0.5)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.water_drop,
            'Meta diaria',
            '${water.dailyGoal} vasos',
            Colors.blue,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.local_fire_department,
            'Racha actual',
            '${water.currentStreak} días',
            Colors.orange,
          ),
          const Divider(height: 20),
          _buildInfoRow(
            Icons.check_circle,
            'Estado',
            water.isGoalCompleted ? 'Meta alcanzada' : 'En progreso',
            water.isGoalCompleted ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
