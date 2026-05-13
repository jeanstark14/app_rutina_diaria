import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/task_provider.dart';
import 'services/theme_provider.dart';
import 'services/user_provider.dart';
import 'services/water_provider.dart';
import 'services/music_service.dart';
import 'services/movie_provider.dart';
import 'services/nutrition_provider.dart';
import 'views/main_view.dart';
import 'views/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');

  bool isFirstTime = true;

  try {
    await initializeDateFormatting('es_ES', null);

    final prefs = await SharedPreferences.getInstance();
    isFirstTime = prefs.getBool('is_first_time') ?? true;
  } catch (e) {
    debugPrint('Error en inicialización: $e');
  }

  // Inicializar servicios
  // NotificationService no tiene método initialize, se inicializa automáticamente

  // Cargar configuración de tema
  final themeProvider = ThemeProvider();
  // ThemeProvider no tiene método loadTheme, se inicializa automáticamente

  // Cargar datos del usuario
  final userProvider = UserProvider();
  // UserProvider no tiene método loadUserData, se inicializa automáticamente

  // Cargar tareas
  final taskProvider = TaskProvider();
  await taskProvider.loadTasks();

  // Cargar datos de hidratación
  final waterProvider = WaterProvider();
  // WaterProvider se inicializa automáticamente en el constructor

  // Inicializar servicio de música
  final musicService = MusicService();
  await musicService.initialize();

  // Inicializar servicio de películas
  final movieProvider = MovieProvider();
  await movieProvider.loadMovies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProvider),
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => taskProvider),
        ChangeNotifierProvider(create: (_) => waterProvider),
        ChangeNotifierProvider(create: (_) => musicService),
        ChangeNotifierProvider(create: (_) => movieProvider),
        ChangeNotifierProvider(create: (_) => NutritionProvider()..loadData()),
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
      home: showOnboarding ? const OnboardingView() : const MainView(),
    );
  }
}
