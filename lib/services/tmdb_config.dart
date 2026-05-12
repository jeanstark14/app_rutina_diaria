// Configuración para la API de TMDB (The Movie Database)
// Para obtener una API key:
// 1. Regístrate en https://www.themoviedb.org/
// 2. Ve a Settings > API > Request an API Key
// 3. Solicita una API Key para "Developer"
// 4. Reemplaza "YOUR_API_KEY_HERE" con tu API key

class TmdbConfig {
  static const String apiKey = '533334408a2003a58b5fd6ea50a1c11e';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';
  static const String language = 'es-ES';
  
  // Verificar si la API key está configurada
  static bool get isConfigured => apiKey != 'YOUR_API_KEY_HERE' && apiKey.isNotEmpty;
  
  // Obtener URL completa de imagen
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    return '$imageBaseUrl$imagePath';
  }
  
  // Obtener URL completa de backdrop
  static String getBackdropUrl(String backdropPath) {
    if (backdropPath.isEmpty) return '';
    return '$backdropBaseUrl$backdropPath';
  }
}
