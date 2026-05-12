import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../services/nutrition_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';
import '../models/nutrition_model.dart';
import '../services/user_provider.dart';
import 'nutrition_profile_setup_view.dart';

class NutritionCenterView extends StatelessWidget {
  const NutritionCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final nutritionProvider = context.watch<NutritionProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    if (nutritionProvider.profile == null) {
      return _buildEmptyProfileState(context, isDark, primaryColor);
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('CENTRO DE ALIMENTACIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const NutritionProfileSetupView())
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => nutritionProvider.loadData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCaloriesCard(nutritionProvider, isDark, primaryColor),
              const SizedBox(height: 24),
              _buildMacrosSection(nutritionProvider, isDark, primaryColor),
              const SizedBox(height: 32),
              _buildRecommendationCard(nutritionProvider.profile!, isDark, primaryColor),
              const SizedBox(height: 32),
              _buildMealHistory(context, nutritionProvider, isDark, primaryColor),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMealModal(context, nutritionProvider, userProvider, isDark, primaryColor),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyProfileState(BuildContext context, bool isDark, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: primaryColor.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            'Configura tu perfil físico',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Necesitamos tus datos para calcular tus metas de calorías y macronutrientes.',
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => const NutritionProfileSetupView())
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('CONFIGURAR AHORA'),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(NutritionProvider provider, bool isDark, Color primaryColor) {
    final progress = (provider.totalCalories / provider.targetCalories).clamp(0.0, 1.0);
    final remaining = (provider.targetCalories - provider.totalCalories).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('CALORÍAS DIARIAS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '${provider.totalCalories.toInt()} / ${provider.targetCalories.toInt()}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  remaining > 0 ? 'Faltan $remaining kcal' : '¡Meta alcanzada!',
                  style: TextStyle(color: remaining > 0 ? primaryColor : Colors.green, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            width: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosSection(NutritionProvider provider, bool isDark, Color primaryColor) {
    final targets = provider.targetMacros;
    
    return Row(
      children: [
        _buildMacroItem('PROTEÍNA', provider.totalProtein, targets['protein']!, Colors.redAccent, isDark),
        const SizedBox(width: 12),
        _buildMacroItem('CARBS', provider.totalCarbs, targets['carbs']!, Colors.orangeAccent, isDark),
        const SizedBox(width: 12),
        _buildMacroItem('GRASAS', provider.totalFat, targets['fat']!, Colors.blueAccent, isDark),
      ],
    );
  }

  Widget _buildMacroItem(String label, double current, double target, Color color, bool isDark) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Text(
              '${current.toInt()}g',
              style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            Text(
              '/ ${target.toInt()}g',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(NutritionProfile profile, bool isDark, Color primaryColor) {
    String title = '';
    String description = '';
    IconData icon = Icons.lightbulb_outline;

    switch (profile.somatotype) {
      case Somatotype.ectomorph:
        title = 'RECOMENDACIÓN ECTOMORFO';
        description = 'Prioriza carbohidratos complejos (avena, arroz integral) y no te saltes comidas. Tu metabolismo es rápido.';
        break;
      case Somatotype.mesomorph:
        title = 'RECOMENDACIÓN MESOMORFO';
        description = 'Mantén un balance 40/30/30. Consume proteínas de alta calidad después de entrenar para mantener tu musculatura.';
        break;
      case Somatotype.endomorph:
        title = 'RECOMENDACIÓN ENDOMORFO';
        description = 'Controla los carbohidratos simples, especialmente por la noche. Prioriza grasas saludables y fibra.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.8), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealHistory(BuildContext context, NutritionProvider provider, bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REGISTRO DE HOY',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5),
        ),
        const SizedBox(height: 16),
        if (provider.dailyLogs.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('No hay comidas registradas hoy.', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...provider.dailyLogs.map((log) => _buildMealItem(context, provider, log, isDark, primaryColor)),
      ],
    );
  }

  Widget _buildMealItem(BuildContext context, NutritionProvider provider, MealLog log, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.fastfood_outlined, color: primaryColor, size: 20),
        ),
        title: Text(log.foodName, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        subtitle: Text('${log.mealType} • ${DateFormat('HH:mm').format(log.timestamp)}', style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${log.calories} kcal', style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
                Text('${log.protein.toInt()}P ${log.carbs.toInt()}C ${log.fat.toInt()}G', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              onPressed: () => provider.deleteMealLog(log.id!),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealModal(BuildContext context, NutritionProvider provider, dynamic userProvider, bool isDark, Color primaryColor) {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final protController = TextEditingController();
    final carbController = TextEditingController();
    final fatController = TextEditingController();
    String mealType = 'Desayuno';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REGISTRAR ALIMENTO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),
              _buildSimpleField(nameController, 'Nombre del alimento', Icons.abc, isDark, primaryColor),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: mealType,
                dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
                decoration: _inputDecoration('Momento del día', Icons.schedule, isDark, primaryColor),
                items: ['Desayuno', 'Almuerzo', 'Cena', 'Snack'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => mealType = val!,
              ),
              const SizedBox(height: 12),
              _buildSimpleField(calController, 'Calorías', Icons.bolt, isDark, primaryColor, keyboard: TextInputType.number),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSimpleField(protController, 'Prot (g)', null, isDark, primaryColor, keyboard: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSimpleField(carbController, 'Carb (g)', null, isDark, primaryColor, keyboard: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSimpleField(fatController, 'Grasa (g)', null, isDark, primaryColor, keyboard: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && calController.text.isNotEmpty) {
                      final log = MealLog(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        mealType: mealType,
                        foodName: nameController.text,
                        calories: int.parse(calController.text),
                        protein: double.tryParse(protController.text) ?? 0,
                        carbs: double.tryParse(carbController.text) ?? 0,
                        fat: double.tryParse(fatController.text) ?? 0,
                        timestamp: DateTime.now(),
                      );
                      provider.addMealLog(log, userProvider);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('AGREGAR REGISTRO', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleField(TextEditingController controller, String label, IconData? icon, bool isDark, Color primaryColor, {TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: _inputDecoration(label, icon, isDark, primaryColor),
    );
  }

  InputDecoration _inputDecoration(String label, IconData? icon, bool isDark, Color primaryColor) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: primaryColor) : null,
      filled: true,
      fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
    );
  }
}
