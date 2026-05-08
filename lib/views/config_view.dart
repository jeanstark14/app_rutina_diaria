import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/theme_provider.dart';
import '../services/user_provider.dart';
import '../services/task_provider.dart';
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
        title: const Text('Editar Nombre', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          cursorColor: primaryColor,
          decoration: InputDecoration(
            hintText: 'Ingresa tu nombre',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                userProvider.updateName(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text('Guardar', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, UserProvider user, TaskProvider task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ZONA DE PELIGRO'),
        content: const Text('¿Estás seguro de que quieres reiniciar todo tu progreso y misiones? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await user.resetProgress();
              await task.clearAllData();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Protocolo de reinicio completado.')));
              }
            },
            child: const Text('SÍ, REINICIAR TODO', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportData(TaskProvider task) {
    final json = task.exportTasksToJson();
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos tácticos copiados al portapapeles (JSON).')));
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
          decoration: const InputDecoration(hintText: 'Pega el código JSON aquí...', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
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
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('CONFIGURACIÓN TÁCTICA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('IDENTIDAD DEL AGENTE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Personaliza tu perfil táctico', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                          backgroundImage: userProvider.profileImage != null ? FileImage(userProvider.profileImage!) : null,
                          child: userProvider.profileImage == null ? Icon(Icons.add_a_photo, color: primaryColor) : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userProvider.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('Nombre de Código', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _editName(userProvider),
                          icon: Icon(Icons.edit, size: 16, color: primaryColor),
                          label: Text('EDITAR NOMBRE', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('EQUIPAMIENTO (SKINS)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('Selecciona tu avatar de héroe', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 20),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSkinOption(HeroSkin.iron_man, 'Iron Man', "assets/skins/iron_man.png", themeProvider),
                  _buildSkinOption(HeroSkin.spider_man, 'Spider-Man', "assets/skins/spider_man.png", themeProvider),
                  _buildSkinOption(HeroSkin.batman, 'Batman', "assets/skins/batman.png", themeProvider),
                  _buildSkinOption(HeroSkin.captain_america, 'Capitán A.', "assets/skins/captain_america.png", themeProvider),
                  _buildSkinOption(HeroSkin.spider_gwen, 'Spider-Gwen', "assets/skins/spider_gwen.png", themeProvider),
                  _buildSkinOption(HeroSkin.sentry, 'Sentry', "assets/skins/sentry.jpg", themeProvider),
                  _buildSkinOption(HeroSkin.superman, 'Superman', "assets/skins/superman.jpg", themeProvider),
                  _buildSkinOption(HeroSkin.luna_snow, 'Luna Snow', "assets/skins/luna_snow.png", themeProvider),
                  _buildSkinOption(HeroSkin.default_geek, 'Clásico', null, themeProvider),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Apariencia y Alertas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        color: isDark ? Colors.black26 : AppTheme.backgroundGrey,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _buildThemeOption('Claro', Icons.wb_sunny, !isDark, themeProvider)),
                          Expanded(child: _buildThemeOption('Oscuro', Icons.dark_mode, isDark, themeProvider)),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 70),
                  _buildListTile(
                    leading: _buildIconContainer(Icons.access_alarm, Colors.orange.withOpacity(0.1), Colors.orange),
                    title: 'Ver Alarmas del Sistema',
                    subtitle: 'Abrir app de reloj nativa',
                    onTap: () => NotificationService().showSystemAlarms(),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Logística de Datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    leading: _buildIconContainer(Icons.backup, Colors.blue.withOpacity(0.1), Colors.blue),
                    title: 'Exportar Inteligencia',
                    subtitle: 'Copiar misiones al portapapeles',
                    onTap: () => _exportData(taskProvider),
                    primaryColor: primaryColor,
                  ),
                  const Divider(height: 1, indent: 70),
                  _buildListTile(
                    leading: _buildIconContainer(Icons.download, Colors.green.withOpacity(0.1), Colors.green),
                    title: 'Importar Inteligencia',
                    subtitle: 'Restaurar misiones desde JSON',
                    onTap: () => _importData(taskProvider),
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('Zona de Peligro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: _buildListTile(
                leading: _buildIconContainer(Icons.delete_forever, Colors.red.withOpacity(0.1), Colors.red),
                title: 'REINICIAR TODO EL SISTEMA',
                subtitle: 'Borra XP, nivel y misiones',
                onTap: () => _confirmReset(context, userProvider, taskProvider),
                primaryColor: Colors.red,
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text('${themeProvider.heroName} SYSTEM v1.1.0', style: const TextStyle(color: AppTheme.textGrey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinOption(HeroSkin skin, String label, String? imagePath, ThemeProvider provider) {
    bool isSelected = provider.currentSkin == skin;
    final primaryColor = provider.primaryColor;
    
    return GestureDetector(
      onTap: () => provider.setSkin(skin),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
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
                border: Border.all(color: isSelected ? primaryColor : Colors.transparent, width: 2),
                image: imagePath != null ? DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover) : null,
              ),
              child: imagePath == null ? const Icon(Icons.shield, color: Colors.white, size: 30) : null,
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : AppTheme.textGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, IconData icon, bool isSelected, ThemeProvider provider) {
    final primaryColor = provider.primaryColor;
    return GestureDetector(
      onTap: () => provider.setThemeMode(label == 'Oscuro' ? ThemeMode.dark : ThemeMode.light),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? (provider.isDarkMode ? Colors.black26 : Colors.white) : Colors.transparent,
          borderRadius: BorderRadius.circular(35),
          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? primaryColor : AppTheme.textGrey, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? (provider.isDarkMode ? Colors.white : AppTheme.textBlack) : AppTheme.textGrey,
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
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
