import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:admin_processes/utils/logger.dart';

/// Platform-specific database initialization
class DatabasePlatform {
  static bool _isInitialized = false;

  /// Initialize the appropriate database factory for the current platform
  static void initialize() {
    if (_isInitialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Desktop platforms use FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      AppLogger.info('Database initialized for desktop platform: ${Platform.operatingSystem}', 'DatabasePlatform');
    } else {
      // Mobile platforms (iOS/Android) use the default sqflite
      AppLogger.info('Database initialized for mobile platform: ${Platform.operatingSystem}', 'DatabasePlatform');
    }

    _isInitialized = true;
  }

  /// Check if the current platform is desktop
  static bool get isDesktop =>
      Platform.isWindows || Platform.isLinux || Platform.isMacOS;

  /// Check if the current platform is mobile
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
}
