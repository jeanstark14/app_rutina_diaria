import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nutrition_model.dart';
import '../services/nutrition_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';

class NutritionProfileSetupView extends StatefulWidget {
  const NutritionProfileSetupView({super.key});

  @override
  State<NutritionProfileSetupView> createState() => _NutritionProfileSetupViewState();
}

class _NutritionProfileSetupViewState extends State<NutritionProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _gender = 'male';
  double _activityLevel = 1.2;
  Somatotype _somatotype = Somatotype.mesomorph;

  @override
  void initState() {
    super.initState();
    final profile = context.read<NutritionProvider>().profile;
    if (profile != null) {
      _weightController.text = profile.weight.toString();
      _heightController.text = profile.height.toString();
      _ageController.text = profile.age.toString();
      _gender = profile.gender;
      _activityLevel = profile.activityLevel;
      _somatotype = profile.somatotype;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('PERFIL NUTRICIONAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('DATOS FÍSICOS', isDark),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _weightController,
                label: 'Peso (kg)',
                icon: Icons.monitor_weight_outlined,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _heightController,
                label: 'Talla (cm)',
                icon: Icons.height,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ageController,
                label: 'Edad (años)',
                icon: Icons.cake_outlined,
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle('GÉNERO', isDark),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSelectableCard(
                    label: 'Hombre',
                    icon: Icons.male,
                    isSelected: _gender == 'male',
                    onTap: () => setState(() => _gender = 'male'),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 16),
                  _buildSelectableCard(
                    label: 'Mujer',
                    icon: Icons.female,
                    isSelected: _gender == 'female',
                    onTap: () => setState(() => _gender = 'female'),
                    primaryColor: primaryColor,
                    isDark: isDark,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              _buildSectionTitle('TIPO DE CUERPO', isDark),
              const SizedBox(height: 12),
              _buildSomatotypeSelection(isDark, primaryColor),
              
              const SizedBox(height: 32),
              _buildSectionTitle('NIVEL DE ACTIVIDAD', isDark),
              const SizedBox(height: 12),
              _buildActivityLevelDropdown(isDark, primaryColor),
              
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  child: const Text('GUARDAR PERFIL', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: isDark ? AppTheme.darkSurface : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requerido';
        if (double.tryParse(value) == null) return 'Número inválido';
        return null;
      },
    );
  }

  Widget _buildSelectableCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected 
              ? primaryColor.withOpacity(0.1) 
              : (isDark ? AppTheme.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : (isDark ? Colors.white70 : Colors.black54),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSomatotypeSelection(bool isDark, Color primaryColor) {
    return Column(
      children: [
        _buildSomatotypeItem(
          Somatotype.ectomorph, 
          'Ectomorfo', 
          'Naturalmente delgado, dificultad para ganar grasa o músculo.',
          isDark, 
          primaryColor
        ),
        const SizedBox(height: 12),
        _buildSomatotypeItem(
          Somatotype.mesomorph, 
          'Mesomorfo', 
          'Atlético, gana músculo con facilidad, estructura ósea ancha.',
          isDark, 
          primaryColor
        ),
        const SizedBox(height: 12),
        _buildSomatotypeItem(
          Somatotype.endomorph, 
          'Endomorfo', 
          'Estructura ósea pesada, tendencia a ganar grasa con facilidad.',
          isDark, 
          primaryColor
        ),
      ],
    );
  }

  Widget _buildSomatotypeItem(Somatotype type, String title, String desc, bool isDark, Color primaryColor) {
    final isSelected = _somatotype == type;
    return GestureDetector(
      onTap: () => setState(() => _somatotype = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? primaryColor.withOpacity(0.1) 
            : (isDark ? AppTheme.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check : Icons.accessibility_new_outlined, 
                color: isSelected ? Colors.white : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? primaryColor : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelDropdown(bool isDark, Color primaryColor) {
    final levels = {
      1.2: 'Sedentario (Poco o nada de ejercicio)',
      1.375: 'Ligero (Ejercicio 1-3 días/semana)',
      1.55: 'Moderado (Ejercicio 3-5 días/semana)',
      1.725: 'Fuerte (Ejercicio 6-7 días/semana)',
      1.9: 'Atleta (Entrenamientos intensos diarios)',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: _activityLevel,
          isExpanded: true,
          dropdownColor: isDark ? AppTheme.darkSurface : Colors.white,
          items: levels.entries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(
                e.value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _activityLevel = val);
          },
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final profile = NutritionProfile(
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        gender: _gender,
        activityLevel: _activityLevel,
        somatotype: _somatotype,
      );
      
      context.read<NutritionProvider>().saveProfile(profile);
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente')),
      );
    }
  }
}
