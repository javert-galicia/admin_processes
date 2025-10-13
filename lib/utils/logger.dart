import 'package:flutter/foundation.dart';

/// Clase para manejo de logs que se comporta diferente en debug vs release
class AppLogger {
  static const String _tag = 'AdminProcesses';

  /// Log de información general (solo en debug)
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] INFO: $message');
    }
  }

  /// Log de advertencias (solo en debug)
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] WARNING: $message');
    }
  }

  /// Log de errores (siempre se muestra, pero sin información sensible en release)
  static void error(String message, [Object? error, String? tag]) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] ERROR: $message');
      if (error != null) {
        print('[$_tag${tag != null ? ':$tag' : ''}] ERROR DETAILS: $error');
      }
    } else {
      // En release, solo log genérico sin detalles
      print('[$_tag] An error occurred in ${tag ?? 'application'}');
    }
  }

  /// Log de debug (solo en debug)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] DEBUG: $message');
    }
  }

  /// Log de éxito (solo en debug)
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      print('[$_tag${tag != null ? ':$tag' : ''}] SUCCESS: $message');
    }
  }
}