import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/movie_model.dart';

class MovieDatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'movie_agenda.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE movie_agenda(
            id TEXT PRIMARY KEY,
            title TEXT,
            description TEXT,
            posterUrl TEXT,
            backdropUrl TEXT,
            releaseDate TEXT,
            voteAverage REAL,
            genres TEXT,
            actors TEXT,
            director TEXT,
            isInAgenda INTEGER,
            isFavorite INTEGER DEFAULT 0,
            runtime INTEGER DEFAULT 0,
            addedToAgendaAt INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE movie_agenda ADD COLUMN isFavorite INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE movie_agenda ADD COLUMN runtime INTEGER DEFAULT 0');
        }
      },
    );
  }

  static Future<void> insertMovie(MovieModel movie) async {
    final db = await database;
    await db.insert(
      'movie_agenda',
      {
        ...movie.toJson(),
        'genres': movie.genres.join(','),
        'actors': movie.actors.join(','),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<MovieModel>> getAllMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('movie_agenda', orderBy: 'releaseDate ASC');
    return List.generate(maps.length, (i) {
      return MovieModel.fromJson(maps[i]);
    });
  }

  static Future<void> deleteMovie(String id) async {
    final db = await database;
    await db.delete(
      'movie_agenda',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('movie_agenda');
  }
}
