import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService extends ChangeNotifier {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentMusicPath;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentFileName;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  String? get currentMusicPath => _currentMusicPath;
  String? get currentFileName => _currentFileName;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get hasMusic => _currentMusicPath != null;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> initialize() async {
    // Cargar la última música seleccionada
    await _loadLastMusic();
    
    // Configurar listeners del audio player
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
      // Opcional: reproducir en loop automáticamente
      // play();
    });
  }

  Future<void> _loadLastMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentMusicPath = prefs.getString('last_music_path');
      _currentFileName = prefs.getString('last_music_filename');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading last music: $e');
    }
  }

  Future<void> _saveLastMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentMusicPath != null) {
        await prefs.setString('last_music_path', _currentMusicPath!);
      }
      if (_currentFileName != null) {
        await prefs.setString('last_music_filename', _currentFileName!);
      }
    } catch (e) {
      debugPrint('Error saving last music: $e');
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Para Android 13 (API 33) y superior, se usa Permission.audio
      // Para versiones anteriores, se usa Permission.storage
      
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
      ].request();

      final isAudioGranted = statuses[Permission.audio]?.isGranted ?? false;
      final isStorageGranted = statuses[Permission.storage]?.isGranted ?? false;

      return isAudioGranted || isStorageGranted;
    } else if (Platform.isIOS) {
      // iOS utiliza el selector de archivos del sistema que no requiere permisos de almacenamiento
      return true;
    }
    return true;
  }

  Future<void> selectMusicFile() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Solicitar permisos
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Se necesitan permisos para acceder a archivos de música');
      }

      // Abrir selector de archivos
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'flac'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        _currentMusicPath = file.path;
        _currentFileName = file.name;
        
        // Guardar para uso futuro
        await _saveLastMusic();
        
        // Preparar el audio player
        await _audioPlayer.setSource(DeviceFileSource(_currentMusicPath!));
        
        debugPrint('Música seleccionada: $_currentFileName');
      }
    } catch (e) {
      debugPrint('Error selecting music file: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      if (_currentMusicPath == null) {
        throw Exception('No hay música seleccionada');
      }

      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing music: $e');
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing music: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping music: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _position = position;
      notifyListeners();
    } catch (e) {
      debugPrint('Error seeking music: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  String get formattedDuration {
    return _formatDuration(_duration);
  }

  String get formattedPosition {
    return _formatDuration(_position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  double get progressPercent {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  void clearCurrentMusic() async {
    await stop();
    _currentMusicPath = null;
    _currentFileName = null;
    _duration = Duration.zero;
    _position = Duration.zero;
    
    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_music_path');
    await prefs.remove('last_music_filename');
    
    notifyListeners();
  }
}
