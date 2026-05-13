import 'package:flutter_dotenv/flutter_dotenv.dart';

class TmdbConfig {
  static String get apiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String backdropBaseUrl = 'https://image.tmdb.org/t/p/w1280';
  static const String language = 'es-ES';
  
  static bool get isConfigured => apiKey.isNotEmpty;
  
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    return '$imageBaseUrl$imagePath';
  }
  
  static String getBackdropUrl(String backdropPath) {
    if (backdropPath.isEmpty) return '';
    return '$backdropBaseUrl$backdropPath';
  }
}