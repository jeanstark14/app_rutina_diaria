# 📱 App Rutina Diaria

Una aplicación Flutter completa para la gestión de rutinas diarias, diseñada para ayudarte a organizar tus tareas, mantener el enfoque y mejorar tu productividad diaria.

## 📋 Descripción del Proyecto

**App Rutina Diaria** es una aplicación móvil integral que permite a los usuarios:

- ✅ **Gestión de Tareas**: Crear, editar y eliminar tareas diarias
- 📅 **Agenda Personal**: Organizar actividades por fechas y horas
- 🎯 **Modo Enfoque**: Sesiones de concentración con temporizador
- 📊 **Estadísticas**: Visualización del progreso y cumplimiento de metas
- 🌙 **Modo Oscuro/Claro**: Personalización de la interfaz
- 🔔 **Notificaciones**: Recordatorios para tareas importantes
- 📈 **Seguimiento Semanal**: Planificación y revisión semanal

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

### 🎯 Gestión de Tareas
- Creación de tareas con título, descripción y fecha
- Categorización de tareas
- Prioridades (Alta, Media, Baja)
- Estado de completación

### ⏰ Modo Enfoque
- Temporizador Pomodoro integrado
- Sesiones de trabajo personalizables
- Descansos programados
- Estadísticas de productividad

### 📊 Estadísticas y Progreso
- Gráficos de cumplimiento diario
- Seguimiento semanal/mensual
- Métricas de productividad
- Historial de tareas completadas

### 🎨 Personalización
- Tema claro/oscuro automático
- Configuración de colores
- Tipografías personalizadas
- Interfaz adaptativa

## 🔧 Configuración y Personalización

### Variables de Entorno
No se requieren variables de entorno para esta aplicación. Todos los datos se almacenan localmente.

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

### v1.0.0 (Actual)
- ✅ Gestión básica de tareas
- ✅ Modo enfoque con temporizador
- ✅ Estadísticas simples
- ✅ Tema claro/oscuro
- ✅ Notificaciones básicas

### Próximas Funcionalidades
- 🔄 Sincronización en la nube
- 🔄 Colaboración en equipo
- 🔄 Integración con calendarios externos
- 🔄 Modo offline mejorado
- 🔄 Exportación de datos

## 📱 Compatibilidad

### Android
- **Versión mínima**: Android 5.0 (API 21)
- **Versión recomendada**: Android 8.0+ (API 26)
- **Arquitecturas**: ARM64, ARMv7

### iOS
- **Versión mínima**: iOS 11.0
- **Dispositivos**: iPhone 5s y superiores

---

**¡Gracias por usar App Rutina Diaria!** 🎉

Si te gusta el proyecto, no olvides darle una ⭐ en GitHub y compartirlo con tus amigos.
