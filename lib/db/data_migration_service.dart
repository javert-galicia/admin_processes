import 'package:admin_processes/db/database_helper.dart';
import 'package:admin_processes/data/process_list_localized.dart';
import 'package:admin_processes/utils/logger.dart';

class DataMigrationService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Migrate data from the static map to SQLite database
  static Future<void> migrateToDatabase() async {
    // Check if data is already migrated
    if (await _dbHelper.hasData()) {
      AppLogger.info('Database already contains data, skipping migration.', 'Migration');
      return;
    }

    AppLogger.info('Starting data migration to SQLite...', 'Migration');

    try {
      // Migrate data for each language
      for (final entry in processListLocalized.entries) {
        final language = entry.key;
        final processStudies = entry.value;

        AppLogger.info('Migrating ${processStudies.length} processes for language $language', 'Migration');

        for (final processStudy in processStudies) {
          await _dbHelper.insertProcessStudy(processStudy, language);
        }
      }

      AppLogger.success('Data migration completed successfully!', 'Migration');
    } catch (e) {
      AppLogger.error('Error during data migration', e, 'Migration');
      rethrow;
    }
  }

  /// Force re-migration (clears existing data and migrates again)
  static Future<void> forceMigration() async {
    AppLogger.warning('Forcing data re-migration...', 'Migration');

    try {
      await _dbHelper.clearAllData();
      await migrateToDatabase();
    } catch (e) {
      AppLogger.error('Error during forced migration', e, 'Migration');
      rethrow;
    }
  }

  /// Get available languages from database
  static Future<List<String>> getAvailableLanguages() async {
    return await _dbHelper.getAvailableLanguages();
  }

  /// Check if database is initialized and has data
  static Future<bool> isDatabaseReady() async {
    return await _dbHelper.hasData();
  }
}
