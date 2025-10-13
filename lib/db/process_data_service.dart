import 'package:admin_processes/db/database_helper.dart';
import 'package:admin_processes/db/data_migration_service.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/utils/logger.dart';

class ProcessDataService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static bool _isInitialized = false;

  /// Initialize the service and ensure data migration is complete
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Ensure data is migrated to the database
      await DataMigrationService.migrateToDatabase();
      _isInitialized = true;
    } catch (e) {
      AppLogger.error('Failed to initialize ProcessDataService', e, 'DataService');
      rethrow;
    }
  }

  /// Get all process studies for a specific language
  /// This replaces the direct access to processListLocalized[language]
  static Future<List<ProcessStudy>> getProcessStudies(String language) async {
    await initialize();

    try {
      return await _dbHelper.getProcessStudiesByLanguage(language);
    } catch (e) {
      AppLogger.error('Error getting process studies for language $language', e, 'DataService');
      return [];
    }
  }

  /// Get all available languages
  static Future<List<String>> getAvailableLanguages() async {
    await initialize();

    try {
      return await _dbHelper.getAvailableLanguages();
    } catch (e) {
      AppLogger.error('Error getting available languages', e, 'DataService');
      return ['es', 'en']; // Fallback to known languages
    }
  }

  /// Add a new process study
  static Future<int> addProcessStudy(
      ProcessStudy processStudy, String language) async {
    await initialize();

    try {
      return await _dbHelper.insertProcessStudy(processStudy, language);
    } catch (e) {
      AppLogger.error('Error adding process study', e, 'DataService');
      rethrow;
    }
  }

  /// Update an existing process study
  static Future<bool> updateProcessStudy(ProcessStudy processStudy) async {
    await initialize();

    try {
      final result = await _dbHelper.updateProcessStudy(processStudy);
      return result > 0;
    } catch (e) {
      AppLogger.error('Error updating process study', e, 'DataService');
      rethrow;
    }
  }

  /// Delete a process study
  static Future<bool> deleteProcessStudy(int id) async {
    await initialize();

    try {
      final result = await _dbHelper.deleteProcessStudy(id);
      return result > 0;
    } catch (e) {
      AppLogger.error('Error deleting process study', e, 'DataService');
      return false;
    }
  }

  /// Search process studies by title or description
  static Future<List<ProcessStudy>> searchProcessStudies(
      String query, String language) async {
    final allStudies = await getProcessStudies(language);

    if (query.isEmpty) return allStudies;

    final lowerQuery = query.toLowerCase();
    return allStudies.where((study) {
      return study.title.toLowerCase().contains(lowerQuery) ||
          study.description.toLowerCase().contains(lowerQuery) ||
          study.processStage.any((stage) =>
              stage.stage.toLowerCase().contains(lowerQuery) ||
              stage.description.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get a specific process study by ID
  static Future<ProcessStudy?> getProcessStudyById(
      int id, String language) async {
    final studies = await getProcessStudies(language);

    try {
      return studies.firstWhere((study) => study.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if the service is ready to use
  static Future<bool> isReady() async {
    return await DataMigrationService.isDatabaseReady();
  }

  /// Force re-initialization (useful for development/testing)
  static Future<void> forceReinitialize() async {
    _isInitialized = false;
    await DataMigrationService.forceMigration();
    await initialize();
  }
}
