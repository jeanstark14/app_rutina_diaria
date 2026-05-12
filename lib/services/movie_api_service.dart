import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';
import 'tmdb_config.dart';

class MovieApiService {
  static const String _language = 'es-ES';

  // Búsqueda de películas
  static Future<List<ApiMovieModel>> searchMovies(String query,
      {int page = 1}) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/search/multi?api_key=${TmdbConfig.apiKey}&language=$_language&query=$query&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => ApiMovieModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  // Obtener detalles de una película específica
  static Future<ApiMovieModel> getMovieDetails(int movieId) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/$movieId?api_key=${TmdbConfig.apiKey}&language=$_language'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiMovieModel.fromJson(data);
      } else {
        throw Exception('Failed to get movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting movie details: $e');
    }
  }

  // Obtener películas populares
  static Future<List<ApiMovieModel>> getPopularMovies({int page = 1}) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/popular?api_key=${TmdbConfig.apiKey}&language=$_language&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => ApiMovieModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get popular movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting popular movies: $e');
    }
  }

  // Obtener películas en cartelera
  static Future<List<ApiMovieModel>> getNowPlayingMovies({int page = 1}) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/now_playing?api_key=${TmdbConfig.apiKey}&language=$_language&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => ApiMovieModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to get now playing movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting now playing movies: $e');
    }
  }

  // Obtener próximas películas
  static Future<List<ApiMovieModel>> getUpcomingMovies({int page = 1}) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/upcoming?api_key=${TmdbConfig.apiKey}&language=$_language&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => ApiMovieModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to get upcoming movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting upcoming movies: $e');
    }
  }

  // Obtener películas similares
  static Future<List<ApiMovieModel>> getSimilarMovies(int movieId,
      {int page = 1}) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/$movieId/similar?api_key=${TmdbConfig.apiKey}&language=$_language&page=$page'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => ApiMovieModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get similar movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting similar movies: $e');
    }
  }

  // Obtener créditos (actores) de una película
  static Future<List<ApiActorModel>> getMovieCredits(int movieId) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/$movieId/credits?api_key=${TmdbConfig.apiKey}&language=$_language'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cast = data['cast'] as List;
        return cast.map((item) => ApiActorModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get movie credits: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting movie credits: $e');
    }
  }

  // Obtener el director de una película
  static Future<String?> getMovieDirector(int movieId) async {
    if (!TmdbConfig.isConfigured) return null;

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/$movieId/credits?api_key=${TmdbConfig.apiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final crew = data['crew'] as List;
        final director = crew.firstWhere(
            (item) => item['job'] == 'Director',
            orElse: () => null);
        return director?['name'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obtener trailers de una película
  static Future<List<ApiVideoModel>> getMovieVideos(int movieId) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/$movieId/videos?api_key=${TmdbConfig.apiKey}&language=$_language'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((item) => ApiVideoModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get movie videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting movie videos: $e');
    }
  }

  // Obtener proveedores de streaming
  static Future<ApiWatchProvidersModel> getWatchProviders(int movieId) async {
    if (!TmdbConfig.isConfigured) {
      throw Exception(
          'API key de TMDB no configurada. Por favor, configura tu API key en tmdb_config.dart');
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${TmdbConfig.baseUrl}/movie/$movieId/watch/providers?api_key=${TmdbConfig.apiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiWatchProvidersModel.fromJson(data);
      } else {
        throw Exception(
            'Failed to get watch providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting watch providers: $e');
    }
  }

  // Método para obtener URL completa de imagen
  static String getImageUrl(String imagePath) {
    return TmdbConfig.getImageUrl(imagePath);
  }

  // Método para obtener URL completa de backdrop
  static String getBackdropUrl(String backdropPath) {
    return TmdbConfig.getBackdropUrl(backdropPath);
  }
}

class ApiActorModel {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;

  const ApiActorModel({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
  });

  factory ApiActorModel.fromJson(Map<String, dynamic> json) {
    return ApiActorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      character: json['character'],
      profilePath: json['profile_path'],
    );
  }

  String? get profileUrl => profilePath != null && profilePath!.isNotEmpty
      ? MovieApiService.getImageUrl(profilePath!)
      : null;
}

// Modelo para respuestas de la API
class ApiMovieModel {
  final bool adult;
  final String backdropPath;
  final List<int> genreIds;
  final int id;
  final String originalLanguage;
  final String originalTitle;
  final String overview;
  final double popularity;
  final String posterPath;
  final String releaseDate;
  final String title;
  final bool video;
  final double voteAverage;
  final int voteCount;
  final List<String> genres;
  final int runtime;
  final String status;
  final String tagline;
  final List<ApiGenreModel> genreList;
  final List<ApiProductionCompanyModel> productionCompanies;
  final List<ApiProductionCountryModel> productionCountries;
  final String spokenLanguages;
  final List<ApiGenreModel> spokenLanguagesList;

  const ApiMovieModel({
    required this.adult,
    required this.backdropPath,
    required this.genreIds,
    required this.id,
    required this.originalLanguage,
    required this.originalTitle,
    required this.overview,
    required this.popularity,
    required this.posterPath,
    required this.releaseDate,
    required this.title,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
    this.genres = const [],
    this.runtime = 0,
    this.status = '',
    this.tagline = '',
    this.genreList = const [],
    this.productionCompanies = const [],
    this.productionCountries = const [],
    this.spokenLanguages = '',
    this.spokenLanguagesList = const [],
  });

  factory ApiMovieModel.fromJson(Map<String, dynamic> json) {
    return ApiMovieModel(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      id: json['id'] ?? 0,
      originalLanguage: json['original_language'] ?? '',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] ?? 0).toDouble(),
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
      title: json['title'] ?? '',
      video: json['video'] ?? false,
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      voteCount: json['vote_count'] ?? 0,
      genres: (json['genres'] as List?)
              ?.map((g) => g['name'].toString())
              .toList() ??
          [],
      runtime: json['runtime'] ?? 0,
      status: json['status'] ?? '',
      tagline: json['tagline'] ?? '',
      genreList: (json['genres'] as List?)
              ?.map((g) => ApiGenreModel.fromJson(g))
              .toList() ??
          [],
      productionCompanies: (json['production_companies'] as List?)
              ?.map((c) => ApiProductionCompanyModel.fromJson(c))
              .toList() ??
          [],
      productionCountries: (json['production_countries'] as List?)
              ?.map((c) => ApiProductionCountryModel.fromJson(c))
              .toList() ??
          [],
      spokenLanguages: json['spoken_languages']?.toString() ?? '',
      spokenLanguagesList: (json['spoken_languages'] as List?)
              ?.map((l) => ApiGenreModel.fromJson(l))
              .toList() ??
          [],
    );
  }

  String? get posterUrl =>
      posterPath.isNotEmpty ? TmdbConfig.getImageUrl(posterPath) : null;

  String? get backdropUrl => backdropPath.isNotEmpty
      ? TmdbConfig.getBackdropUrl(backdropPath)
      : null;

  // Convertir a MovieModel local
  MovieModel toMovieModel() {
    return MovieModel(
      id: id.toString(),
      title: title,
      description: overview,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      genres: genres,
      isInAgenda: false,
    );
  }
}

class ApiGenreModel {
  final int id;
  final String name;

  const ApiGenreModel({
    required this.id,
    required this.name,
  });

  factory ApiGenreModel.fromJson(Map<String, dynamic> json) {
    return ApiGenreModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class ApiProductionCompanyModel {
  final int id;
  final String logoPath;
  final String name;
  final String originCountry;

  const ApiProductionCompanyModel({
    required this.id,
    required this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ApiProductionCompanyModel.fromJson(Map<String, dynamic> json) {
    return ApiProductionCompanyModel(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'] ?? '',
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }
}

class ApiProductionCountryModel {
  final String iso31661;
  final String name;

  const ApiProductionCountryModel({
    required this.iso31661,
    required this.name,
  });

  factory ApiProductionCountryModel.fromJson(Map<String, dynamic> json) {
    return ApiProductionCountryModel(
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class ApiVideoModel {
  final String iso6391;
  final String iso31661;
  final String name;
  final String key;
  final String site;
  final int size;
  final String type;
  final bool official;
  final DateTime publishedAt;
  final String id;

  const ApiVideoModel({
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.key,
    required this.site,
    required this.size,
    required this.type,
    required this.official,
    required this.publishedAt,
    required this.id,
  });

  factory ApiVideoModel.fromJson(Map<String, dynamic> json) {
    return ApiVideoModel(
      iso6391: json['iso_639_1'] ?? '',
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
      key: json['key'] ?? '',
      site: json['site'] ?? '',
      size: json['size'] ?? 0,
      type: json['type'] ?? '',
      official: json['official'] ?? false,
      publishedAt: DateTime.parse(
          json['published_at'] ?? DateTime.now().toIso8601String()),
      id: json['id'] ?? '',
    );
  }

  // Obtener URL del trailer de YouTube
  String? get youtubeUrl {
    if (site.toLowerCase() == 'youtube' && key.isNotEmpty) {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return null;
  }
}

class ApiWatchProvidersModel {
  final ApiResults results;

  const ApiWatchProvidersModel({
    required this.results,
  });

  factory ApiWatchProvidersModel.fromJson(Map<String, dynamic> json) {
    return ApiWatchProvidersModel(
      results: ApiResults.fromJson(json['results'] ?? {}),
    );
  }
}

class ApiResults {
  final Map<String, ApiProviderInfo> providers;

  const ApiResults({
    required this.providers,
  });

  factory ApiResults.fromJson(Map<String, dynamic> json) {
    final Map<String, ApiProviderInfo> providersMap = {};

    // Mapear todos los países posibles
    final countries = [
      'AR',
      'BR',
      'CA',
      'CH',
      'DE',
      'DK',
      'ES',
      'FI',
      'FR',
      'GB',
      'HK',
      'HU',
      'IE',
      'IN',
      'IT',
      'JP',
      'KR',
      'LT',
      'MX',
      'NL',
      'NO',
      'NZ',
      'PE',
      'PL',
      'PT',
      'RU',
      'SE',
      'SG',
      'TH',
      'TR',
      'US',
      'VE'
    ];

    for (String country in countries) {
      if (json[country] != null) {
        providersMap[country] = ApiProviderInfo.fromJson(json[country]);
      }
    }

    return ApiResults(providers: providersMap);
  }

  // Obtener proveedores de España
  ApiProviderInfo get spanishProviders =>
      providers['ES'] ?? const ApiProviderInfo(flatrate: [], buy: [], rent: []);
}

class ApiProviderInfo {
  final List<ApiProvider> flatrate;
  final List<ApiProvider> buy;
  final List<ApiProvider> rent;

  const ApiProviderInfo({
    required this.flatrate,
    required this.buy,
    required this.rent,
  });

  factory ApiProviderInfo.fromJson(Map<String, dynamic> json) {
    return ApiProviderInfo(
      flatrate: (json['flatrate'] as List?)
              ?.map((p) => ApiProvider.fromJson(p))
              .toList() ??
          [],
      buy: (json['buy'] as List?)
              ?.map((p) => ApiProvider.fromJson(p))
              .toList() ??
          [],
      rent: (json['rent'] as List?)
              ?.map((p) => ApiProvider.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ApiProvider {
  final int displayPriority;
  final String logoPath;
  final int providerId;
  final String providerName;
  final int priority;

  const ApiProvider({
    required this.displayPriority,
    required this.logoPath,
    required this.providerId,
    required this.providerName,
    required this.priority,
  });

  factory ApiProvider.fromJson(Map<String, dynamic> json) {
    return ApiProvider(
      displayPriority: json['display_priority'] ?? 0,
      logoPath: json['logo_path'] ?? '',
      providerId: json['provider_id'] ?? 0,
      providerName: json['provider_name'] ?? '',
      priority: json['priority'] ?? 0,
    );
  }
}
