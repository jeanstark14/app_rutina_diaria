import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie_model.dart';
import '../services/movie_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';
import 'movie_detail_view.dart';
import 'api_movie_search_view.dart';
import '../services/movie_api_service.dart';

class MovieCalendarView extends StatefulWidget {
  const MovieCalendarView({super.key});

  @override
  State<MovieCalendarView> createState() => _MovieCalendarViewState();
}

class _MovieCalendarViewState extends State<MovieCalendarView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieProvider>().loadMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final movieProvider = context.watch<MovieProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('AGENDA DE ESTRENOS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: movieProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => movieProvider.loadMovies(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (movieProvider.moviesInAgenda.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'MI AGENDA',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : AppTheme.textGrey,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _buildAgendaList(movieProvider.moviesInAgenda, primaryColor, isDark),
                    ] else
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: _buildEmptyState(primaryColor, isDark),
                      ),
                    
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'RECOMENDADAS PARA TI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : AppTheme.textGrey,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecommendations(primaryColor, isDark),
                    const SizedBox(height: 100), // Espacio para el FAB
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ApiMovieSearchView()),
        ),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text('BUSCAR ESTRENOS', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: primaryColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Tu agenda está vacía',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Busca tus películas favoritas y agrégalas para ver cuánto falta para su estreno.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaList(List<MovieModel> movies, Color primaryColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: movies.map((movie) => _buildMovieCard(movie, primaryColor, isDark)).toList(),
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie, Color primaryColor, bool isDark) {
    final days = movie.daysUntilRelease;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieDetailView(movie: movie)),
        ),
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Poster
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Hero(
                  tag: 'poster_${movie.id}',
                  child: movie.posterUrl != null
                      ? Image.network(
                          movie.posterUrl!,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 100,
                          color: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.movie, color: primaryColor),
                        ),
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Estreno: ${movie.releaseDate}',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                      ),
                      const Spacer(),
                      // Countdown Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: movie.statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: movie.statusColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          movie.releaseStatus.toUpperCase(),
                          style: TextStyle(
                            color: movie.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: movie.isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => context.read<MovieProvider>().toggleFavorite(movie.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmDelete(movie.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendations(Color primaryColor, bool isDark) {
    return FutureBuilder<List<ApiMovieModel>>(
      future: MovieApiService.getPopularMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final movies = snapshot.data!;
        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailView(movie: movie.toMovieModel()),
                  ),
                ),
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Stack(
                          children: [
                            movie.posterPath.isNotEmpty
                                ? Image.network(
                                    movie.posterUrl!,
                                    height: 180,
                                    width: 140,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 180,
                                    width: 140,
                                    color: primaryColor.withOpacity(0.1),
                                    child: Icon(Icons.movie, color: primaryColor),
                                  ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      movie.voteAverage.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Quitar de la agenda?'),
        content: const Text('Esta película ya no aparecerá en tu seguimiento de estrenos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () {
              context.read<MovieProvider>().deleteMovie(id);
              Navigator.pop(context);
            },
            child: const Text('QUITAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
