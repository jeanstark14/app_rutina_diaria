import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/theme_provider.dart';
import '../services/user_provider.dart';
import '../services/task_provider.dart';
import '../services/water_provider.dart';
import '../services/notification_service.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigViewState();
}

class _ConfigViewState extends State<ConfigView> {
  Future<void> _pickImage(UserProvider userProvider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      userProvider.updateProfileImage(image.path);
    }
  }

  void _editName(UserProvider userProvider) {
    final themeProvider = context.read<ThemeProvider>();
    final primaryColor = themeProvider.primaryColor;
    final controller = TextEditingController(text: userProvider.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title:
            const Text('Editar Nombre', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          cursorColor: primaryColor,
          decoration: InputDecoration(
            hintText: 'Ingresa tu nombre',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                userProvider.updateName(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text('Guardar',
                style: TextStyle(
                    color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, UserProvider user, TaskProvider task,
      WaterProvider water) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ZONA DE PELIGRO'),
        content: const Text(
            '¿Estás seguro de que quieres reiniciar todo tu progreso, misiones y datos de hidratación? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await user.resetProgress();
              await task.clearAllData();
              await water.resetWaterProgress();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        'Protocolo de reinicio completado. Todos los datos han sido eliminados.')));
              }
            },
            child: const Text('SÍ, REINICIAR TODO',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportData(TaskProvider task) {
    final json = task.exportTasksToJson();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Datos tácticos copiados al portapapeles (JSON).')));
  }

  void _importData(TaskProvider task) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Inteligencia'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
              hintText: 'Pega el código JSON aquí...',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await task.importTasksFromJson(controller.text);
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('IMPORTAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final userProvider = context.watch<UserProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final waterProvider = context.watch<WaterProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CONFIGURACIÓN TÁCTICA',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('IDENTIDAD DEL AGENTE',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Personaliza tu perfil táctico',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(userProvider),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          backgroundImage: userProvider.profileImage != null
                              ? FileImage(userProvider.profileImage!)
                              : null,
                          child: userProvider.profileImage == null
                              ? Icon(Icons.add_a_photo, color: primaryColor)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userProvider.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('Nombre de Código',
                            style: TextStyle(
                                color: AppTheme.textGrey, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _editName(userProvider),
                          icon: Icon(Icons.edit, size: 16, color: primaryColor),
                          label: Text('EDITAR NOMBRE',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('PROTOCOLO DE HIDRATACIÓN',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Ajusta tu meta diaria de vasos',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 16),
            _buildWaterGoalSettings(
                context, waterProvider, isDark, primaryColor),
            const SizedBox(height: 32),
            const Text('EQUIPAMIENTO (SKINS)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Selecciona tu avatar de héroe',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSkinOption(HeroSkin.iron_man, 'Iron Man',
                      "assets/skins/iron_man.png", themeProvider),
                  _buildSkinOption(HeroSkin.spider_man, 'Spider-Man',
                      "assets/skins/spider_man.png", themeProvider),
                  _buildSkinOption(HeroSkin.batman, 'Batman',
                      "assets/skins/batman.png", themeProvider),
                  _buildSkinOption(HeroSkin.captain_america, 'Capitán A.',
                      "assets/skins/captain_america.png", themeProvider),
                  _buildSkinOption(HeroSkin.spider_gwen, 'Spider-Gwen',
                      "assets/skins/spider_gwen.png", themeProvider),
                  _buildSkinOption(HeroSkin.sentry, 'Sentry',
                      "assets/skins/sentry.jpg", themeProvider),
                  _buildSkinOption(HeroSkin.superman, 'Superman',
                      "assets/skins/superman.jpg", themeProvider),
                  _buildSkinOption(HeroSkin.luna_snow, 'Luna Snow',
                      "assets/skins/luna_snow.png", themeProvider),
                  _buildSkinOption(
                      HeroSkin.default_geek, 'Clásico', null, themeProvider),
                  // Botón de personalización de colores
                  _buildCustomColorOption(themeProvider),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Apariencia y Alertas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            isDark ? Colors.black26 : AppTheme.backgroundGrey,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildThemeOption('Claro', Icons.wb_sunny,
                                  !isDark, themeProvider)),
                          Expanded(
                              child: _buildThemeOption('Oscuro',
                                  Icons.dark_mode, isDark, themeProvider)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 70),
                  _buildListTile(
                    leading: _buildIconContainer(Icons.access_alarm,
                        Colors.orange.withOpacity(0.1), Colors.orange),
                    title: 'Ver Alarmas del Sistema',
                    subtitle: 'Abrir app de reloj nativa',
                    onTap: () => NotificationService().showSystemAlarms(),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Logística de Datos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    leading: _buildIconContainer(Icons.backup,
                        Colors.blue.withOpacity(0.1), Colors.blue),
                    title: 'Exportar Inteligencia',
                    subtitle: 'Copiar misiones al portapapeles',
                    onTap: () => _exportData(taskProvider),
                    primaryColor: primaryColor,
                  ),
                  const Divider(height: 1, indent: 70),
                  _buildListTile(
                    leading: _buildIconContainer(Icons.download,
                        Colors.green.withOpacity(0.1), Colors.green),
                    title: 'Importar Inteligencia',
                    subtitle: 'Restaurar misiones desde JSON',
                    onTap: () => _importData(taskProvider),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Zona de Peligro',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: _buildListTile(
                leading: _buildIconContainer(Icons.delete_forever,
                    Colors.red.withOpacity(0.1), Colors.red),
                title: 'REINICIAR TODO EL SISTEMA',
                subtitle: 'Borra XP, nivel, misiones y racha de hidratación',
                onTap: () => _confirmReset(
                    context, userProvider, taskProvider, waterProvider),
                primaryColor: Colors.red,
              ),
            ),
            const SizedBox(height: 32),
            const Text('SOBRE EL SISTEMA',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textGrey)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ],
              ),
              child: _buildListTile(
                leading: _buildIconContainer(Icons.info_outline,
                    primaryColor.withOpacity(0.1), primaryColor),
                title: 'Información de la App',
                subtitle: 'Jean Diary v1.1.0 • Tu aliado táctico',
                onTap: () => _showAboutDialog(context, themeProvider),
                primaryColor: primaryColor,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text('${themeProvider.heroName} SYSTEM v1.1.0',
                  style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinOption(
      HeroSkin skin, String label, String? imagePath, ThemeProvider provider) {
    bool isSelected = provider.currentSkin == skin && !provider.useCustomColors;
    final primaryColor = provider.primaryColor;

    return GestureDetector(
      onTap: () => provider.setSkin(skin),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: imagePath == null ? primaryColor : null,
                border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: 2),
                image: imagePath != null
                    ? DecorationImage(
                        image: AssetImage(imagePath), fit: BoxFit.cover)
                    : null,
              ),
              child: imagePath == null
                  ? const Icon(Icons.shield, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : AppTheme.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomColorOption(ThemeProvider provider) {
    final isSelected = provider.useCustomColors;
    final primaryColor = provider.primaryColor;

    return GestureDetector(
      onTap: () => _showColorPickerDialog(context, provider),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color:
              isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? LinearGradient(
                        colors: [primaryColor, provider.accentColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color:
                      isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                isSelected ? Icons.palette : Icons.colorize,
                color: isSelected ? Colors.white : Colors.grey,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSelected ? 'Personalizado' : 'Personalizar',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : AppTheme.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context, ThemeProvider provider) {
    Color primaryColor = provider.useCustomColors
        ? provider.primaryColor
        : const Color(0xFF2D62ED);
    Color accentColor = provider.useCustomColors
        ? provider.accentColor
        : const Color(0xFF2D62ED);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Personalizar Paleta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Color Principal',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildColorCircle(Colors.white, primaryColor, (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFFD32F2F), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF1976D2), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF388E3C), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFFFBC02D), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF7B1FA2), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFFE91E63), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF00BCD4), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF795548), primaryColor,
                        (color) {
                      setState(() => primaryColor = color);
                    }),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Color de Acento',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildColorCircle(Colors.white, accentColor, (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFFD32F2F), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF1976D2), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF388E3C), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFFFBC02D), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF7B1FA2), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFFE91E63), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF00BCD4), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                    _buildColorCircle(const Color(0xFF795548), accentColor,
                        (color) {
                      setState(() => accentColor = color);
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Vista previa de tu paleta',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (provider.useCustomColors)
              TextButton(
                onPressed: () {
                  provider.clearCustomColors();
                  Navigator.pop(context);
                },
                child: const Text('Restablecer',
                    style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setCustomColors(primaryColor, accentColor);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child:
                  const Text('Aplicar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(
    Color color,
    Color selectedColor,
    Function(Color) onTap,
  ) {
    final isSelected = color.value == selectedColor.value;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 24)
            : null,
      ),
    );
  }

  Widget _buildThemeOption(
      String label, IconData icon, bool isSelected, ThemeProvider provider) {
    final primaryColor = provider.primaryColor;
    return GestureDetector(
      onTap: () => provider
          .setThemeMode(label == 'Oscuro' ? ThemeMode.dark : ThemeMode.light),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (provider.isDarkMode ? Colors.black26 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(35),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 10)
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? primaryColor : AppTheme.textGrey, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? (provider.isDarkMode ? Colors.white : AppTheme.textBlack)
                    : AppTheme.textGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }

  Widget _buildListTile({
    required Widget leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    required Color primaryColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: leading,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(color: AppTheme.textGrey, fontSize: 12))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildWaterGoalSettings(BuildContext context,
      WaterProvider waterProvider, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: Colors.blue.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meta Diaria',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${waterProvider.dailyGoal} vasos de agua',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${waterProvider.dailyGoal}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.blue.shade600,
              inactiveTrackColor:
                  isDark ? Colors.white10 : Colors.grey.shade200,
              thumbColor: Colors.blue.shade600,
              overlayColor: Colors.blue.withOpacity(0.2),
              valueIndicatorColor: Colors.blue.shade600,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: waterProvider.dailyGoal.toDouble(),
              min: 4,
              max: 16,
              divisions: 12,
              label: '${waterProvider.dailyGoal} vasos',
              onChanged: (value) {
                waterProvider.setDailyGoal(value.toInt());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '4 vasos',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500,
                ),
              ),
              Text(
                '16 vasos',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (waterProvider.currentStreak > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Racha actual: ${waterProvider.currentStreak} días',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, ThemeProvider themeProvider) {
    final primaryColor = themeProvider.primaryColor;
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.shield, color: primaryColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jean Diary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Sistema Táctico de Productividad',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  'Jean Diary es tu aliado táctico para organizar tu día, mantener tu racha de productividad y alcanzar tus objetivos de salud. '
                  'Un ecosistema gamificado que integra gestión de tareas, hidratación, nutrición y entretenimiento cinematográfico.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? Colors.white.withOpacity(0.8)
                        : AppTheme.textBlack,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Características
              Text(
                'CARACTERÍSTICAS PRINCIPALES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureRow(Icons.check_circle, 'Gestión de tareas y misiones',
                  primaryColor),
              _buildFeatureRow(Icons.local_fire_department,
                  'Sistema de rachas y niveles XP', primaryColor),
              _buildFeatureRow(
                  Icons.water_drop, 'Tracker de hidratación inteligente', primaryColor),
              _buildFeatureRow(
                  Icons.restaurant, 'Centro de Nutrición y Macronutrientes', primaryColor),
              _buildFeatureRow(
                  Icons.movie, 'Calendario Cinematográfico (TMDB)', primaryColor),
              _buildFeatureRow(Icons.palette, 'Skins personalizables de héroes',
                  primaryColor),
              _buildFeatureRow(Icons.insights, 'Estadísticas de productividad y salud',
                  primaryColor),
              _buildFeatureRow(
                  Icons.dark_mode, 'Modo oscuro y personalización', primaryColor),

              const SizedBox(height: 20),

              // Información técnica
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Versión', 'v1.1.0', primaryColor),
                    _buildInfoRow(
                        'Skin Activo', themeProvider.heroName, primaryColor),
                    _buildInfoRow('Desarrollador', 'Jean Pierre', primaryColor),
                    _buildInfoRow('Año', '2026', primaryColor),
                    _buildInfoRow('Persistencia', 'Permanente*', primaryColor),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Nota sobre persistencia
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.storage,
                      size: 16,
                      color: Colors.blue.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '*Los datos se almacenan localmente en tu dispositivo de forma permanente usando SharedPreferences. '
                        'Permanecerán guardados indefinidamente hasta que desinstales la app o uses el botón "Reiniciar Todo el Sistema". '
                        'No hay límite de tiempo ni espacio definido - años de historial pueden conservarse.',
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.4,
                          color: isDark
                              ? Colors.white.withOpacity(0.7)
                              : Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Agradecimientos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.favorite, color: Colors.red.shade400, size: 20),
                    const SizedBox(height: 8),
                    Text(
                      '¡Gracias por usar Jean Diary!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cada misión completada te acerca a tu mejor versión.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
