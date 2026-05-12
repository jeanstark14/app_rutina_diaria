import 'package:flutter/material.dart';

class MovieModel {
  final String id;
  final String title;
  final String? description;
  final String? posterUrl;
  final String? backdropUrl;
  final String releaseDate; // Formato YYYY-MM-DD
  final double voteAverage;
  final List<String> genres;
  final List<String> actors;
  final String? director;
  final bool isInAgenda;
  final bool isFavorite;
  final int runtime;
  final DateTime? addedToAgendaAt;

  MovieModel({
    required this.id,
    required this.title,
    this.description,
    this.posterUrl,
    this.backdropUrl,
    required this.releaseDate,
    this.voteAverage = 0.0,
    this.genres = const [],
    this.actors = const [],
    this.director,
    this.isInAgenda = false,
    this.isFavorite = false,
    this.runtime = 0,
    this.addedToAgendaAt,
  });

  // Calcular días restantes para el estreno
  int get daysUntilRelease {
    try {
      final releaseDateTime = DateTime.parse(releaseDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return releaseDateTime.difference(today).inDays;
    } catch (e) {
      return -1; // Error en la fecha
    }
  }

  // Estado del estreno
  String get releaseStatus {
    final days = daysUntilRelease;
    if (days < 0) return 'Estrenada';
    if (days == 0) return 'SE ESTRENA HOY';
    if (days == 1) return 'Falta 1 día';
    return 'Faltan $days días';
  }

  Color get statusColor {
    final days = daysUntilRelease;
    if (days < 0) return Colors.grey;
    if (days == 0) return Colors.redAccent;
    if (days <= 7) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  MovieModel copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? backdropUrl,
    String? releaseDate,
    double? voteAverage,
    List<String>? genres,
    List<String>? actors,
    String? director,
    bool? isInAgenda,
    bool? isFavorite,
    int? runtime,
    DateTime? addedToAgendaAt,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      voteAverage: voteAverage ?? this.voteAverage,
      genres: genres ?? this.genres,
      actors: actors ?? this.actors,
      director: director ?? this.director,
      isInAgenda: isInAgenda ?? this.isInAgenda,
      isFavorite: isFavorite ?? this.isFavorite,
      runtime: runtime ?? this.runtime,
      addedToAgendaAt: addedToAgendaAt ?? this.addedToAgendaAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'genres': genres,
      'actors': actors,
      'director': director,
      'isInAgenda': isInAgenda ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'runtime': runtime,
      'addedToAgendaAt': addedToAgendaAt?.millisecondsSinceEpoch,
    };
  }

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'],
      posterUrl: json['posterUrl'],
      backdropUrl: json['backdropUrl'],
      releaseDate: json['releaseDate'] ?? '',
      voteAverage: (json['voteAverage'] ?? 0.0).toDouble(),
      genres: json['genres'] is String 
          ? (json['genres'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : List<String>.from(json['genres'] ?? []),
      actors: json['actors'] is String
          ? (json['actors'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : List<String>.from(json['actors'] ?? []),
      director: json['director'],
      isInAgenda: json['isInAgenda'] == 1 || json['isInAgenda'] == true,
      isFavorite: json['isFavorite'] == 1 || json['isFavorite'] == true,
      runtime: json['runtime'] ?? 0,
      addedToAgendaAt: json['addedToAgendaAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['addedToAgendaAt'])
          : null,
    );
  }
}

