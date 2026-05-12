import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie_model.dart';
import '../services/movie_provider.dart';
import '../services/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/movie_api_service.dart';
import '../services/movie_database_service.dart';
import '../services/tmdb_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MovieDetailView extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailView({super.key, required this.movie});

  @override
  State<MovieDetailView> createState() => _MovieDetailViewState();
}

class _MovieDetailViewState extends State<MovieDetailView> {
  List<ApiActorModel> _cast = [];
  List<ApiMovieModel> _similarMovies = [];
  List<ApiVideoModel> _videos = [];
  ApiWatchProvidersModel? _providers;
  bool _isLoadingExtra = true;

  @override
  void initState() {
    super.initState();
    _loadExtraData();
  }

  Future<void> _loadExtraData() async {
    try {
      final movieId = int.tryParse(widget.movie.id);
      if (movieId == null) return;

      final results = await Future.wait([
        MovieApiService.getMovieCredits(movieId),
        MovieApiService.getSimilarMovies(movieId),
        MovieApiService.getMovieVideos(movieId),
        MovieApiService.getWatchProviders(movieId),
        MovieApiService.getMovieDetails(movieId),
        MovieApiService.getMovieDirector(movieId),
      ]);

      if (mounted) {
        final fullDetails = results[4] as ApiMovieModel;
        final director = results[5] as String?;
        
        setState(() {
          _cast = results[0] as List<ApiActorModel>;
          _similarMovies = results[1] as List<ApiMovieModel>;
          _videos = results[2] as List<ApiVideoModel>;
          _providers = results[3] as ApiWatchProvidersModel;
          _isLoadingExtra = false;
        });

        // Actualizar el modelo local con datos técnicos si es necesario
        if (widget.movie.runtime == 0 || widget.movie.director == null) {
          final updatedMovie = widget.movie.copyWith(
            runtime: fullDetails.runtime,
            director: director,
          );
          
          // Si ya está en la agenda, actualizamos la DB para persistir estos datos
          if (context.read<MovieProvider>().isMovieInAgenda(widget.movie.id)) {
            await MovieDatabaseService.insertMovie(updatedMovie);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading extra data: $e');
      if (mounted) {
        setState(() => _isLoadingExtra = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final movieProvider = context.watch<MovieProvider>();
    final isDark = themeProvider.isDarkMode;
    final primaryColor = themeProvider.primaryColor;
    final inAgenda = movieProvider.isMovieInAgenda(widget.movie.id);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.backgroundGrey,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark, inAgenda),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(widget.movie, isDark, primaryColor),
                  const SizedBox(height: 24),
                  _buildCountdownSection(widget.movie, isDark),
                  const SizedBox(height: 24),
                  _buildActionButtons(context, movieProvider, inAgenda, primaryColor),
                  const SizedBox(height: 32),
                  _buildSectionTitle('SINOPSIS', isDark),
                  const SizedBox(height: 12),
                  Text(
                    widget.movie.description ?? 'Sin descripción disponible.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Sección de Trailers
                  if (!_isLoadingExtra && _videos.isNotEmpty) ...[
                    _buildSectionTitle('TRAILERS Y VIDEOS', isDark),
                    const SizedBox(height: 16),
                    _buildVideoSection(_videos, isDark, primaryColor),
                    const SizedBox(height: 32),
                  ],

                  // Sección de Dónde Ver
                  if (!_isLoadingExtra && _providers != null) ...[
                    _buildSectionTitle('DISPONIBLE EN', isDark),
                    const SizedBox(height: 16),
                    _buildProviderSection(_providers!, isDark),
                    const SizedBox(height: 32),
                  ],

                  // Sección de Actores
                  _buildSectionTitle('REPARTO PRINCIPAL', isDark),
                  const SizedBox(height: 16),
                  _isLoadingExtra 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildActorsList(_cast, isDark),
                  
                  const SizedBox(height: 32),

                  // Sección de Películas Relacionadas
                  _buildSectionTitle('PELÍCULAS RELACIONADAS', isDark),
                  const SizedBox(height: 16),
                  _isLoadingExtra 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSimilarMoviesList(_similarMovies, isDark, primaryColor),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, bool inAgenda) {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: isDark ? AppTheme.darkBackground : Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (inAgenda)
          IconButton(
            icon: Icon(
              widget.movie.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.movie.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () => context.read<MovieProvider>().toggleFavorite(widget.movie.id),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'poster_${widget.movie.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.movie.posterUrl != null)
                Image.network(widget.movie.posterUrl!, fit: BoxFit.cover)
              else
                Container(color: Colors.grey.shade900),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MovieModel movie, bool isDark, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        if (movie.director != null && movie.director!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Dirigida por ${movie.director}',
            style: TextStyle(
              fontSize: 16,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (movie.runtime > 0)
              _buildBadge(Icons.timer_outlined, '${movie.runtime} min', isDark, primaryColor),
            ...movie.genres.take(3).map((g) => _buildGenreBadge(g, isDark, primaryColor)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.calendar_month, color: primaryColor, size: 18),
            const SizedBox(width: 6),
            Text(
              'Fecha de estreno: ${movie.releaseDate}',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              movie.voteAverage.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String text, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreBadge(String text, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCountdownSection(MovieModel movie, bool isDark) {
    final days = movie.daysUntilRelease;
    final statusColor = movie.statusColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.timer, color: statusColor, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  days < 0 ? 'YA ESTRENADA' : 'CUENTA REGRESIVA',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                Text(
                  movie.releaseStatus,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MovieProvider provider, bool inAgenda, Color primaryColor) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          if (inAgenda) {
            provider.deleteMovie(widget.movie.id);
          } else {
            provider.addMovie(widget.movie);
          }
        },
        icon: Icon(inAgenda ? Icons.check_circle : Icons.calendar_month),
        label: Text(
          inAgenda ? 'AGREGADA A MI AGENDA' : 'AGREGAR A MI AGENDA',
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: inAgenda ? Colors.green : primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.textGrey,
        fontWeight: FontWeight.bold,
        fontSize: 13,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildActorsList(List<ApiActorModel> actors, bool isDark) {
    if (actors.isEmpty) return const Text('No hay información del reparto.');

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: actors.length,
        itemBuilder: (context, index) {
          final actor = actors[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  backgroundImage: actor.profileUrl != null 
                    ? NetworkImage(actor.profileUrl!) 
                    : null,
                  child: actor.profileUrl == null 
                    ? const Icon(Icons.person, color: Colors.grey) 
                    : null,
                ),
                const SizedBox(height: 8),
                Text(
                  actor.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSimilarMoviesList(List<ApiMovieModel> movies, bool isDark, Color primaryColor) {
    if (movies.isEmpty) return const Text('No hay películas relacionadas.');

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailView(movie: movie.toMovieModel()),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterPath.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.posterUrl!,
                          height: 150,
                          width: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 150,
                            width: 120,
                            color: primaryColor.withOpacity(0.1),
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 150,
                            width: 120,
                            color: primaryColor.withOpacity(0.1),
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: 150,
                          width: 120,
                          color: primaryColor.withOpacity(0.1),
                          child: const Icon(Icons.movie, color: Colors.grey),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoSection(List<ApiVideoModel> videos, bool isDark, Color primaryColor) {
    final trailers = videos.where((v) => v.type.toLowerCase() == 'trailer').toList();
    final displayVideos = trailers.isNotEmpty ? trailers : videos;

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayVideos.length,
        itemBuilder: (context, index) {
          final video = displayVideos[index];
          return GestureDetector(
            onTap: () async {
              final url = video.youtubeUrl;
              if (url != null) {
                final uri = Uri.parse(url);
                try {
                  // Intentar abrir en aplicación externa (YouTube)
                  final launched = await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                  
                  if (!launched) {
                    // Si falla, intentar modo por defecto
                    await launchUrl(uri, mode: LaunchMode.platformDefault);
                  }
                } catch (e) {
                  debugPrint('Error al lanzar trailer: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('No se pudo abrir el trailer. ¿Tienes YouTube instalado?'),
                        action: SnackBarAction(
                          label: 'REINTENTAR',
                          onPressed: () => launchUrl(uri, mode: LaunchMode.platformDefault),
                        ),
                      ),
                    );
                  }
                }
              }
            },
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: NetworkImage('https://img.youtube.com/vi/${video.key}/0.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black38,
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderSection(ApiWatchProvidersModel providers, bool isDark) {
    // Usamos PE por defecto o ES si está disponible, o simplemente tomamos el primero que tenga datos
    final results = providers.results.providers;
    ApiProviderInfo? info;
    
    // Intentar obtener proveedores locales (España o Perú son comunes en el contexto del usuario)
    if (results.containsKey('PE')) info = results['PE'];
    else if (results.containsKey('ES')) info = results['ES'];
    else if (results.isNotEmpty) info = results.values.first;

    if (info == null || info.flatrate.isEmpty) {
      return Text(
        'Información de streaming no disponible en tu región.',
        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 13),
      );
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: info.flatrate.length,
        itemBuilder: (context, index) {
          final provider = info!.flatrate[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: provider.providerName,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  TmdbConfig.getImageUrl(provider.logoPath),
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
