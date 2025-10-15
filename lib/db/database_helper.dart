import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/model/process_stage.dart';
import 'package:admin_processes/db/database_platform.dart';
import 'package:admin_processes/utils/logger.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    // Initialize platform-specific database factory
    DatabasePlatform.initialize();

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get platform-specific database path
    String dbPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // For desktop platforms, use application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbDir = Directory(join(appDocDir.path, 'admin_processes_db'));
      
      // Create directory if it doesn't exist
      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
        AppLogger.info('Created database directory: ${dbDir.path}', 'DatabaseHelper');
      }
      
      dbPath = join(dbDir.path, 'admin_processes.db');
      AppLogger.info('Database path (desktop): $dbPath', 'DatabaseHelper');
    } else {
      // For mobile platforms, use getDatabasesPath()
      dbPath = join(await getDatabasesPath(), 'admin_processes.db');
      AppLogger.info('Database path (mobile): $dbPath', 'DatabaseHelper');
    }

    return await openDatabase(
      dbPath,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create ProcessStudy table
    await db.execute('''
      CREATE TABLE process_studies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        language TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isDeletable INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create ProcessStage table
    await db.execute('''
      CREATE TABLE process_stages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        processStudyId INTEGER NOT NULL,
        stage TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (processStudyId) REFERENCES process_studies (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute(
        'CREATE INDEX idx_process_studies_language ON process_studies (language)');
    await db.execute(
        'CREATE INDEX idx_process_stages_study_id ON process_stages (processStudyId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add isDeletable column for existing databases
      await db.execute(
          'ALTER TABLE process_studies ADD COLUMN isDeletable INTEGER NOT NULL DEFAULT 1');
    }

    if (oldVersion < 3) {
      // Mark system processes as non-deletable
      final systemProcessTitles = [
        // Spanish
        'Proceso Administrativo', '5S', 'Six Sigma (DMAIC)',
        'Proceso de Selección',
        'Marca', 'La Pirámide de Maslow', 'Análisis FODA', 'Plan de Negocios',
        'SMART', 'MECE', 'MECE2',
        // English
        'Administrative Process', 'Selection Process', 'Brand',
        'Maslow\'s Hierarchy of Needs',
        'SWOT Analysis', 'Business Plan',
        // Legacy processes (old names)
        'Gestión de Personal', 'Personnel Management', 'Control de Inventario',
        'Inventory Control', 'Atención al Cliente', 'Customer Service'
      ];

      for (String title in systemProcessTitles) {
        await db.execute(
            'UPDATE process_studies SET isDeletable = 0 WHERE title = ?',
            [title]);
      }
    }
  }

  // Insert a ProcessStudy with its stages
  Future<int> insertProcessStudy(
      ProcessStudy processStudy, String language) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Insert the ProcessStudy
      final studyId = await txn.insert('process_studies', {
        'language': language,
        'title': processStudy.title,
        'description': processStudy.description,
        'isDeletable': processStudy.isDeletable ? 1 : 0,
      });

      // Insert all ProcessStages
      for (final stage in processStudy.processStage) {
        await txn.insert('process_stages', {
          'processStudyId': studyId,
          'stage': stage.stage,
          'description': stage.description,
        });
      }

      return studyId;
    });
  }

  // Get all ProcessStudies for a specific language
  Future<List<ProcessStudy>> getProcessStudiesByLanguage(
      String language) async {
    final db = await database;

    final studiesData = await db.query(
      'process_studies',
      where: 'language = ?',
      whereArgs: [language],
      orderBy: 'id',
    );

    List<ProcessStudy> studies = [];

    for (final studyData in studiesData) {
      final stages = await getProcessStagesByStudyId(studyData['id'] as int);
      studies.add(ProcessStudy.fromMap(studyData, stages));
    }

    return studies;
  }

  // Get all ProcessStages for a specific ProcessStudy
  Future<List<ProcessStage>> getProcessStagesByStudyId(int studyId) async {
    final db = await database;

    final stagesData = await db.query(
      'process_stages',
      where: 'processStudyId = ?',
      whereArgs: [studyId],
      orderBy: 'id',
    );

    return stagesData.map((data) => ProcessStage.fromMap(data)).toList();
  }

  // Get all available languages
  Future<List<String>> getAvailableLanguages() async {
    final db = await database;

    final result = await db.query(
      'process_studies',
      columns: ['DISTINCT language'],
      orderBy: 'language',
    );

    return result.map((row) => row['language'] as String).toList();
  }

  // Check if database has data
  Future<bool> hasData() async {
    final db = await database;

    final result = await db.query('process_studies', limit: 1);
    return result.isNotEmpty;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('process_stages');
      await txn.delete('process_studies');
    });
  }

  // Update a ProcessStudy
  Future<int> updateProcessStudy(ProcessStudy processStudy) async {
    final db = await database;

    return await db.update(
      'process_studies',
      processStudy.toMap(),
      where: 'id = ?',
      whereArgs: [processStudy.id],
    );
  }

  // Delete a ProcessStudy and its stages
  Future<int> deleteProcessStudy(int id) async {
    final db = await database;

    return await db.delete(
      'process_studies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
