import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/task_provider.dart';
import 'services/theme_provider.dart';
import 'services/user_provider.dart';
import 'views/agenda_view.dart';
import 'views/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isFirstTime = true;

  try {
    await initializeDateFormatting('es_ES', null);

    final prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('is_first_time') ?? true;
  } catch (e) {
    debugPrint('Error en inicialización: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MyApp(showOnboarding: isFirstTime),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'App Jean diary',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF2D62ED),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2D62ED),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: showOnboarding ? const OnboardingView() : const AgendaView(),
    );
  }
}
