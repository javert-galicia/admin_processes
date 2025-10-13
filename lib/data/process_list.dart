import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/db/process_data_service.dart';
import 'package:flutter/material.dart';
import 'package:admin_processes/utils/logger.dart';

/// Get process list from SQLite database
/// This replaces the old static data approach
Future<List<ProcessStudy>> getProcessList(BuildContext context) async {
  final locale = Localizations.localeOf(context).languageCode;
  try {
    return await ProcessDataService.getProcessStudies(locale);
  } catch (e) {
    AppLogger.error('Error loading process list for locale $locale', e, 'ProcessList');
    // Fallback to Spanish if the requested language fails
    if (locale != 'es') {
      try {
        return await ProcessDataService.getProcessStudies('es');
      } catch (e2) {
        AppLogger.error('Error loading fallback Spanish process list: $e2');
        return [];
      }
    }
    return [];
  }
}

/// Synchronous version for backward compatibility (DEPRECATED)
/// Use getProcessList() instead for better performance and error handling
@Deprecated('Use getProcessList() instead. This method may cause blocking.')
List<ProcessStudy> getProcessListSync(BuildContext context) {
  // This is a temporary bridge for existing synchronous code
  // In a real migration, you should convert all calling code to async
  final locale = Localizations.localeOf(context).languageCode;

  // Return empty list and print warning
  AppLogger.error(
      'WARNING: getProcessListSync is deprecated. Use getProcessList() instead.');
  AppLogger.error('Locale requested: $locale');

  return [];
}
