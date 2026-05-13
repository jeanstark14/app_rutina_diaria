# 📱 App Rutina Diaria

Una aplicación Flutter completa para la gestión de rutinas diarias, diseñada para ayudarte a organizar tus tareas, mantener el enfoque y mejorar tu productividad diaria.

## 📋 Descripción del Proyecto

**Jean Diary** es una aplicación móvil integral con enfoque gamificado que permite a los usuarios:

- ✅ **Gestión de Tareas**: Crear, editar y eliminar misiones diarias
- 📅 **Agenda Personal**: Organizar actividades por fechas y horas
- 🎯 **Modo Enfoque**: Sesiones de concentración con temporizador Pomodoro
- 📊 **Estadísticas**: Visualización del progreso y cumplimiento de metas (Productividad + Salud + Cine)
- 🌙 **Modo Oscuro/Claro**: Personalización de la interfaz
- 🔔 **Notificaciones**: Recordatorios para tareas importantes
- 📈 **Seguimiento Semanal**: Planificación y revisión semanal
- 💧 **Tracker de Hidratación**: Control diario de consumo de agua con rachas
- 🍎 **Centro de Nutrición**: Control de calorías, macronutrientes y somatotipos
- 🎬 **Calendario Cinematográfico**: Seguimiento de estrenos con integración TMDB
- 🦸 **Skins de Héroes**: Personalización con avatares de superhéroes
- 🎨 **Colores Personalizados**: Paleta de colores totalmente personalizable
- 📤 **Exportar/Importar Datos**: Sincronización mediante JSON

## 🏗️ Arquitectura Técnica

### Tecnologías Utilizadas
- **Flutter** 3.3.0+ - Framework multiplataforma
- **Dart** - Lenguaje de programación principal
- **SQLite** - Base de datos local con `sqflite`
- **Provider** - Gestión de estado
- **Google Fonts** - Tipografías personalizadas
- **Image Picker** - Selección de imágenes
- **Shared Preferences** - Almacenamiento local

### Estructura del Proyecto
```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── task_model.dart      # Modelo de datos para tareas
├── services/
│   ├── background_timer_service.dart  # Servicio de temporizador
│   ├── database_service.dart          # Gestión de base de datos
│   ├── notification_service.dart      # Sistema de notificaciones
│   ├── task_provider.dart            # Provider para tareas
│   ├── theme_provider.dart           # Gestión de temas
│   └── user_provider.dart            # Gestión de usuario
├── theme/
│   └── app_theme.dart      # Configuración de temas
├── views/
│   ├── agenda_view.dart              # Vista principal de agenda
│   ├── calendar_view.dart            # Vista de calendario
│   ├── config_view.dart              # Configuración
│   ├── focus_mode_view.dart          # Modo enfoque
│   ├── master_schedule_view.dart     # Horario maestro
│   ├── mission_complete_view.dart    # Misiones completadas
│   ├── onboarding_view.dart          # Introducción
│   ├── stats_view.dart              # Estadísticas
│   └── weekly_schedule_view.dart     # Horario semanal
└── widgets/
    └── create_task_form.dart         # Formulario de creación de tareas
```

## 🚀 Cómo Ejecutar el Proyecto

### Requisitos Previos
- **Flutter SDK** 3.3.0 o superior
- **Android Studio** o **VS Code** con extensiones Flutter
- **Android SDK** (para desarrollo Android)
- **Xcode** (para desarrollo iOS, solo macOS)

### Instalación y Ejecución

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/jeanstark14/app_rutina_diaria.git
   cd app_rutina_diaria
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Verificar configuración:**
   ```bash
   flutter doctor
   ```

4. **Ejecutar la aplicación:**
   ```bash
   flutter run
   ```

## 📲 Descargar e Instalar APK

### Opción 1: Descargar APK Precompilado
1. Ve a la sección [**Releases**](https://github.com/jeanstark14/app_rutina_diaria/releases) del repositorio
2. Descarga la última versión del APK (`app-rutina-diaria-v1.0.0.apk`)
3. En tu dispositivo Android, habilita **"Fuentes desconocidas"** en Configuración > Seguridad
4. Instala el APK descargado

### Opción 2: Compilar APK Manualmente
1. **Clonar el repositorio** (ver sección anterior)
2. **Navegar al directorio del proyecto:**
   ```bash
   cd app_rutina_diaria
   ```
3. **Generar APK de release:**
   ```bash
   flutter build apk --release
   ```
4. **El APK se generará en:**
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### Opción 3: Usar GitHub Actions (Automático)
El repositorio está configurado para generar automáticamente APKs con cada release. Simplemente crea una nueva release y el APK se generará automáticamente.

## 📱 Características Principales

### 🎯 Gestión de Tareas y Misiones
- Sistema de misiones con XP y niveles gamificados
- Creación de tareas con título, descripción y fecha
- Categorización y prioridades (Alta, Media, Baja)
- Estado de completación con sistema de recompensas
- Sistema de rachas para mantener la motivación

### ⏰ Modo Enfoque Pomodoro
- Temporizador Pomodoro integrado con sesiones personalizables
- Descansos programados y notificaciones de sesión
- Estadísticas de productividad y tiempo de enfoque
- Modo de concentración sin distracciones

### 📊 Estadísticas y Progreso
- Gráficos interactivos de cumplimiento diario/semanal
- Sistema de niveles y experiencia (XP)
- Métricas detalladas de productividad
- Historial completo de misiones completadas
- Dashboard con estadísticas en tiempo real

### 🍎 Centro de Nutrición y Macronutrientes
- **Perfil Físico Personalizado**: Cálculo de metas basado en peso, altura, edad y nivel de actividad
- **Análisis de Somatotipo**: Recomendaciones específicas para Ectomorfos, Mesomorfos y Endomorfos
- **Tracker de Calorías**: Control diario de ingesta vs objetivo calórico
- **Desglose de Macros**: Seguimiento de Proteínas, Carbohidratos y Grasas
- **Registro de Comidas**: Historial diario detallado con tipos de comida (Desayuno, Almuerzo, etc.)
- **Recompensas XP**: Gana experiencia al cumplir tus metas nutricionales diarias

### 🎬 Calendario Cinematográfico (TMDB)
- **Búsqueda Global**: Acceso a la base de datos de The Movie Database (TMDB)
- **Cuenta Regresiva**: Visualiza cuántos días faltan para los estrenos de tu agenda
- **Detalles Premium**: Sinopsis, reparto, calificación, posters y trailers
- **Favoritos**: Guarda las películas que más te interesan para un acceso rápido
- **Recomendaciones Inteligentes**: Descubre películas populares y tendencias
- **Sincronización de Estadísticas**: Seguimiento de tiempo invertido en cine

### 💧 Tracker de Hidratación
- Control diario de consumo de agua (4-16 vasos)
- Sistema de rachas de hidratación
- Notificaciones personalizables para recordatorios
- Estadísticas de consumo semanal/mensual
- Meta diaria ajustable con slider interactivo

### 🦸 Sistema de Skins y Personalización
- **8 Skins de Héroes disponibles**:
  - Iron Man, Spider-Man, Batman, Capitán América
  - Spider-Gwen, Sentry, Superman, Luna Snow
  - Skin clásico "Geek" personalizable
- **Paleta de Colores Personalizada**:
  - Selector de color principal y de acento
  - Vista previa en tiempo real
  - 9 colores predefinidos + opción personalizada
  - Aplicación instantánea a toda la interfaz

### 🌙 Temas y Apariencia
- Modo claro/oscuro con transiciones suaves
- Interfaz adaptativa con Material 3
- Tipografías personalizadas con Google Fonts
- Animaciones y micro-interacciones fluidas

### 📤 Gestión de Datos
- **Exportación**: Copia de seguridad en formato JSON
- **Importación**: Restauración de misiones y progreso
- Almacenamiento local permanente con SharedPreferences
- Sincronización manual entre dispositivos



### 🔔 Sistema de Notificaciones
- Notificaciones locales para tareas y recordatorios
- Alarmas del sistema integradas
- Personalización de tonos y frecuencias
- Modo silencio programable

## 🔧 Configuración y Personalización

### ⚙️ Configuración de API (Opcional)

Para habilitar la búsqueda de películas desde la base de datos de TMDB:

1. **Obtener API Key de TMDB**
   - Regístrate en [https://www.themoviedb.org/](https://www.themoviedb.org/)
   - Solicita una API Key gratuita en Settings > API
   - Verifica tu email para activar la API Key

2. **Configurar en el proyecto**
   ```bash
   # Editar el archivo de configuración
   lib/services/tmdb_config.dart
   
   # Reemplazar la API Key
   static const String apiKey = 'TU_API_KEY_AQUI';
   ```

3. **Documentación completa**
   - Ver `API_SETUP.md` para instrucciones detalladas
   - Incluye solución de problemas y mejores prácticas

### Variables de Entorno
No se requieren variables de entorno adicionales. Todos los datos se almacenan localmente.

### Base de Datos
- **Motor**: SQLite
- **Ubicación**: Almacenamiento local del dispositivo
- **Migraciones**: Automáticas

### Notificaciones
- Requiere permisos de notificación en Android 6.0+
- Compatible con Android 8.0+ (Notification Channels)

## 📸 Capturas de Pantalla

*Agrega aquí capturas de pantalla de la aplicación*

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si quieres mejorar el proyecto:

1. **Fork** el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. **Commit** tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. **Push** a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un **Pull Request**

### Guía de Estilo
- Sigue las convenciones de estilo de Dart
- Añade comentarios a funciones complejas
- Incluye pruebas unitarias cuando sea posible

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Contacto

- **Autor**: Jean Stark
- **GitHub**: [@jeanstark14](https://github.com/jeanstark14)
- **Email**: [tu-email@example.com]

## 🐛 Reportar Issues

¿Encontraste un bug? ¿Tienes una sugerencia?

1. Revisa si ya existe un [issue](https://github.com/jeanstark14/app_rutina_diaria/issues)
2. Si no existe, crea un nuevo issue con:
   - Título descriptivo
   - Pasos para reproducir el problema
   - Capturas de pantalla si es aplicable
   - Información del dispositivo y versión de la app

## 🔄 Versiones

### v1.2.0 (Actual)
- ✅ **Centro de Nutrición**: Perfiles físicos, somatotipos y metas de macros
- ✅ **Calendario Cinematográfico**: Integración completa con TMDB y cuenta regresiva
- ✅ **Inteligencia de Datos**: Dashboard de estadísticas unificado
- ✅ **XP Dinámico**: Recompensas por hidratación y nutrición
- ✅ Mejoras en la interfaz y optimización de carga

### v1.1.0
- ✅ Sistema de misiones con XP y niveles gamificados
- ✅ Tracker de hidratación con rachas (4-16 vasos)
- ✅ 8 skins de héroes personalizables
- ✅ Paleta de colores personalizada con 9+ opciones
- ✅ Exportación/Importación de datos en formato JSON
- ✅ Modo enfoque Pomodoro mejorado
- ✅ Estadísticas avanzadas y dashboard en tiempo real
- ✅ Sistema de notificaciones y alarmas integradas
- ✅ Almacenamiento local permanente con SharedPreferences
- ✅ Interfaz con Material 3 y animaciones fluidas

### v1.0.0
- ✅ Gestión básica de tareas
- ✅ Modo enfoque con temporizador
- ✅ Estadísticas simples
- ✅ Tema claro/oscuro
- ✅ Notificaciones básicas

### Próximas Funcionalidades
- 🔄 Sincronización en la nube
- 🔄 Colaboración en equipo
- 🔄 Integración con calendarios externos (Google Calendar, Outlook)
- 🔄 Modo offline mejorado
- 🔄 Widget para pantalla principal
- 🔄 Integración con asistentes de voz (Google Assistant, Siri)

## 📱 Compatibilidad

### Android
- **Versión mínima**: Android 5.0 (API 21)
- **Versión recomendada**: Android 8.0+ (API 26)
- **Arquitecturas**: ARM64, ARMv7

### iOS
- **Versión mínima**: iOS 11.0
- **Dispositivos**: iPhone 5s y superiores

---

**¡Gracias por usar Jean Diary!** 🎉

Si te gusta el proyecto, no olvides darle una ⭐ en GitHub y compartirlo con tus amigos.
