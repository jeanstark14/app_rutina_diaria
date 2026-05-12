import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movie_database_service.dart';

class MovieProvider extends ChangeNotifier {
  List<MovieModel> _moviesInAgenda = [];
  bool _isLoading = false;

  List<MovieModel> get moviesInAgenda => _moviesInAgenda;
  bool get isLoading => _isLoading;

  Future<void> loadMovies() async {
    _isLoading = true;
    notifyListeners();
    try {
      _moviesInAgenda = await MovieDatabaseService.getAllMovies();
    } catch (e) {
      debugPrint('Error loading agenda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMovie(MovieModel movie) async {
    final updatedMovie = movie.copyWith(
      isInAgenda: true,
      addedToAgendaAt: DateTime.now(),
    );
    await MovieDatabaseService.insertMovie(updatedMovie);
    await loadMovies();
  }

  Future<void> toggleFavorite(String id) async {
    final index = _moviesInAgenda.indexWhere((m) => m.id == id);
    if (index != -1) {
      final movie = _moviesInAgenda[index];
      final updatedMovie = movie.copyWith(isFavorite: !movie.isFavorite);
      await MovieDatabaseService.insertMovie(updatedMovie);
      await loadMovies();
    }
  }

  Future<void> deleteMovie(String id) async {
    await MovieDatabaseService.deleteMovie(id);
    await loadMovies();
  }

  bool isMovieInAgenda(String id) {
    return _moviesInAgenda.any((m) => m.id == id);
  }
}
