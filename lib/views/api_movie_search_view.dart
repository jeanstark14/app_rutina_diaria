import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/movie_api_service.dart';
import '../services/movie_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';
import 'movie_detail_view.dart';

class ApiMovieSearchView extends StatefulWidget {
  const ApiMovieSearchView({super.key});

  @override
  State<ApiMovieSearchView> createState() => _ApiMovieSearchViewState();
}

class _ApiMovieSearchViewState extends State<ApiMovieSearchView> {
  final TextEditingController _searchController = TextEditingController();
  List<ApiMovieModel> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('BUSCAR PELÍCULAS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(primaryColor, isDark),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? _buildEmptyState(primaryColor, isDark)
                    : _buildSearchResults(primaryColor, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color primaryColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Nombre de la película...',
          hintStyle: TextStyle(color: AppTheme.textGrey),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onSubmitted: (value) => _performSearch(value),
      ),
    );
  }

  Widget _buildSearchResults(Color primaryColor, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final apiMovie = _searchResults[index];
        return _buildMovieCard(apiMovie, primaryColor, isDark);
      },
    );
  }

  Widget _buildMovieCard(ApiMovieModel apiMovie, Color primaryColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailView(movie: apiMovie.toMovieModel()),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: apiMovie.posterPath.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: apiMovie.posterUrl!,
                        width: 70,
                        height: 100,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => Container(
                          width: 70,
                          height: 100,
                          color: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.movie, color: primaryColor),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 100,
                        color: primaryColor.withOpacity(0.1),
                        child: Icon(Icons.movie, color: primaryColor),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      apiMovie.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apiMovie.releaseDate.isNotEmpty ? apiMovie.releaseDate : 'Sin fecha',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          apiMovie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGrey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 60, color: primaryColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Busca una película para agregar',
            style: TextStyle(color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final results = await MovieApiService.searchMovies(query);
      setState(() {
        _searchResults = results.where((m) => m.title.isNotEmpty).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
