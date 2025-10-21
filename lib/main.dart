import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';
import 'package:admin_processes/view/process_items.dart';
import 'package:admin_processes/view/add_process_screen.dart';
import 'package:admin_processes/view/faq_screen.dart';
import 'package:admin_processes/l10n/localization.dart';
import 'package:admin_processes/db/process_data_service.dart';
import 'package:admin_processes/db/database_platform.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:admin_processes/model/process_stage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:convert';

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);
final ValueNotifier<String> flagStyle = ValueNotifier('flags');

class SettingsManager {
  static const String _localeKey = 'app_locale';
  static const String _themeKey = 'dark_mode';
  static const String _flagStyleKey = 'flag_style';

  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  static Future<void> saveFlagStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_flagStyleKey, style);
  }

  static Future<String> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'en';
  }

  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<String> loadFlagStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_flagStyleKey) ?? 'flags';
  }

  static Future<bool> exportData() async {
    try {
      // Get available languages
      final languages = await ProcessDataService.getAvailableLanguages();
      
      // Get all deletable processes for all languages
      final Map<String, List<Map<String, dynamic>>> allProcesses = {};
      bool hasData = false;
      
      for (String language in languages) {
        final processes = await ProcessDataService.getProcessStudies(language);
        final deletableProcesses = processes.where((p) => p.isDeletable).toList();
        
        if (deletableProcesses.isNotEmpty) {
          hasData = true;
          allProcesses[language] = deletableProcesses.map((process) {
            return {
              'id': process.id,
              'title': process.title,
              'description': process.description,
              'language': process.language,
              'isDeletable': process.isDeletable,
              'stages': process.processStage.map((stage) => {
                'id': stage.id,
                'processStudyId': stage.processStudyId,
                'stage': stage.stage,
                'description': stage.description,
              }).toList(),
            };
          }).toList();
        }
      }
      
      if (!hasData) {
        return false; // No user-created processes to export
      }
      
      // Create export data with metadata
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'dataType': 'userProcesses',
        'processes': allProcesses,
      };
      
      // Try to get export location from user. On some Android setups the save dialog may not be available.
      String? outputFile;
      try {
        outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Select export location',
          fileName: 'user_processes_${DateTime.now().millisecondsSinceEpoch}.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
      } catch (e) {
        // FilePicker may throw on some platforms; we'll fallback to app external directory and share the file
        outputFile = null;
      }

      // If user selected a location, write file there
      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonEncode(exportData));
        return true;
      }

      // Fallback for Android / platforms without a save dialog: write to external app directory and offer share
      try {
        Directory? baseDir;
        if (Platform.isAndroid) {
          baseDir = await getExternalStorageDirectory();
        } else {
          baseDir = await getApplicationDocumentsDirectory();
        }

        if (baseDir == null) return false;

        final fallbackPath = '${baseDir.path}${Platform.pathSeparator}user_processes_${DateTime.now().millisecondsSinceEpoch}.json';
        final fallbackFile = File(fallbackPath);
        await fallbackFile.writeAsString(jsonEncode(exportData));

        // Use share_plus to let the user save/share the file
        try {
          await Share.shareXFiles([XFile(fallbackFile.path)], text: 'Exported user processes');
        } catch (shareError) {
          // If sharing fails, at least the file exists in the app directory
        }

        return true;
      } catch (e) {
        // Provide error details in debug mode
        // ignore: avoid_print
        print('exportData error: $e');
        return false;
      }
    } catch (e) {
      // ignore: avoid_print
      print('exportData caught exception: $e');
      return false;
    }
  }

  static Future<bool> importData() async {
    try {
      // Let user select file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select file to import',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final contents = await file.readAsString();
        final Map<String, dynamic> importData = jsonDecode(contents);
        
        // Validate import data format
        if (importData['dataType'] != 'userProcesses' || importData['processes'] == null) {
          return false; // Invalid format
        }
        
        final Map<String, dynamic> processesData = importData['processes'];
        
        // Import processes for each language
        for (String language in processesData.keys) {
          final List<dynamic> processesForLanguage = processesData[language];
          
          for (var processData in processesForLanguage) {
            // Create ProcessStage objects
            final List<ProcessStage> stages = (processData['stages'] as List<dynamic>)
                .map((stageData) => ProcessStage(
                      stageData['stage'],
                      stageData['description'],
                    ))
                .toList();
            
            // Create ProcessStudy object
            final ProcessStudy process = ProcessStudy(
              processData['title'],
              processData['description'],
              stages,
              language: language,
              isDeletable: processData['isDeletable'] ?? true,
            );
            
            // Add to database
            await ProcessDataService.addProcessStudy(process, language);
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database platform before running the app
  DatabasePlatform.initialize();
  
  // Load saved settings
  await _loadSettings();
  
  runApp(AdminProcessApp());
}

Future<void> _loadSettings() async {
  // Load saved locale
  final savedLocale = await SettingsManager.loadLocale();
  appLocale.value = Locale(savedLocale);
  
  // Load saved theme
  final savedTheme = await SettingsManager.loadTheme();
  isDarkMode.value = savedTheme;

  // Load saved flag style
  final savedFlagStyle = await SettingsManager.loadFlagStyle();
  flagStyle.value = savedFlagStyle;
}

class AdminProcessApp extends StatelessWidget {
  AdminProcessApp({super.key});

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      // Esquema de colores profesional - Azul corporativo moderno
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1565C0), // Azul corporativo principal
        brightness: Brightness.light,
        primary: const Color(0xFF1565C0), // Azul corporativo
        onPrimary: Colors.white,
        secondary: const Color(0xFF0277BD), // Azul secundario
        onSecondary: Colors.white,
        surface: const Color(0xFFF8F9FA), // Gris claro para superficies
        onSurface: const Color(0xFF1A1A1A), // Texto principal
        background: const Color(0xFFFFFFFF), // Fondo blanco limpio
        onBackground: const Color(0xFF1A1A1A),
        error: const Color(0xFFD32F2F),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1565C0), // Azul corporativo
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF1565C0);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF1565C0), width: 2.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        splashRadius: 24,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: Colors.black, 
        collapsedIconColor: Colors.black,
        textColor: Colors.black,
        collapsedTextColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFFF8F9FA), // Usar el mismo color de superficie del tema
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      // Esquema de colores para modo oscuro
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1B4F72), // Azul marino para modo oscuro
        brightness: Brightness.dark,
        primary: const Color(0xFF1B4F72), // Azul marino
        onPrimary: const Color(0xFFFFFFFF),
        secondary: const Color(0xFF81C784), // Verde secundario
        onSecondary: const Color(0xFF1A1A1A),
        surface: const Color(0xFF1E1E1E), // Superficie oscura
        onSurface: const Color(0xFFE0E0E0), // Texto claro
        background: const Color(0xFF121212), // Fondo oscuro
        onBackground: const Color(0xFFE0E0E0),
        error: const Color(0xFFEF5350),
        onError: const Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1B4F72), // Azul marino
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black54,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nunito',
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF1B4F72);
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(const Color(0xFFFFFFFF)),
        side: const BorderSide(color: Color(0xFF1B4F72), width: 2.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        materialTapTargetSize: MaterialTapTargetSize.padded,
        splashRadius: 24,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: Colors.white, 
        collapsedIconColor: Colors.white,
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B4F72),
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 2,
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkMode,
          builder: (context, darkMode, _) {
            return MaterialApp(
          scrollBehavior: AppScrollBehavior(),
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('es')],
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomeTree(),
        );
      },
    );
      },
    );
  }
}

class HomeTree extends StatefulWidget {
  const HomeTree({super.key});

  @override
  State<HomeTree> createState() => _HomeTreeState();
}

class _HomeTreeState extends State<HomeTree> {
  late final PageController _pageController;
  late Future<void> _initializationFuture;
  Future<List<ProcessStudy>>? _processListFuture;
  String? _currentLanguage;
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializationFuture = _initializeApp();
  }

  /// Initialize the app and database
  Future<void> _initializeApp() async {
    await ProcessDataService.initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  /// Get cached process list for the current language
  Future<List<ProcessStudy>> _getCachedProcessList(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;

    // If language changed or first time, create new future
    if (_processListFuture == null || _currentLanguage != currentLanguage) {
      _currentLanguage = currentLanguage;
      _processListFuture = getProcessList(context);
    }

    return _processListFuture!;
  }

  /// Handle process deletion - refresh the process list
  void _handleProcessDeleted() {
    setState(() {
      // Invalidate the cached process list to trigger a refresh
      _processListFuture = null;

      // The page adjustment will be handled by the FutureBuilder
      // when the new process list is loaded
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, initSnapshot) {
        if (initSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)?.get('processTitle') ??
                  'Procesos Administrativos'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Inicializando base de datos...'),
                ],
              ),
            ),
          );
        }

        if (initSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)?.get('processTitle') ??
                  'Procesos Administrativos'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${initSnapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initializationFuture = ProcessDataService.initialize();
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        return FutureBuilder<List<ProcessStudy>>(
          future: _getCachedProcessList(context),
          builder: (context, processSnapshot) {
            if (processSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      AppLocalizations.of(context)?.get('processTitle') ??
                          'Procesos Administrativos'),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (processSnapshot.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      AppLocalizations.of(context)?.get('processTitle') ??
                          'Procesos Administrativos'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error cargando procesos: ${processSnapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final processList = processSnapshot.data ?? [];

            if (processList.isEmpty) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(
                      AppLocalizations.of(context)?.get('processTitle') ??
                          'Procesos Administrativos'),
                ),
                body: const Center(
                  child: Text('No hay procesos disponibles'),
                ),
              );
            }

            return _buildMainScaffold(context, processList);
          },
        );
      },
    );
  }

  Widget _buildMainScaffold(
      BuildContext context, List<ProcessStudy> processList) {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (context, currentPage, _) {
        // Ensure current page is within bounds
        if (currentPage >= processList.length && processList.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _currentPageNotifier.value = 0;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
          });
        }
        
        return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.get('processTitle') ??
            'Procesos Administrativos'),
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(context, processList),
            icon: const Icon(Icons.search),
            tooltip: AppLocalizations.of(context)?.get('searchProcess') ?? 'Buscar proceso',
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddProcessScreen(
                    language: Localizations.localeOf(context).languageCode,
                  ),
                ),
              );

              // Si se agregó un proceso, recargar la lista
              if (result == true) {
                setState(() {
                  _processListFuture = null;
                  _currentLanguage = null;
                });
              }
            },
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)?.get('addProcess') ??
                'Add process',
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AboutDialog(
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/logo_400.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  applicationVersion: '2.0.1.0',
                  applicationName:
                      AppLocalizations.of(context)?.get('processTitle') ??
                          'Procesos Administrativos',
                  applicationLegalese: '2025 MIT License',
                  children: [
                    Text(
                        AppLocalizations.of(context)?.get('description') ?? ''),
                    const SizedBox(height: 16),
                    Linkify(
                      onOpen: (link) async {
                        final Uri url = Uri.parse(link.url);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      text: AppLocalizations.of(context)?.get('aboutInfo') ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                      ),
                      linkStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    AppLocalizations.of(context)?.get('processTitle') ??
                        'Procesos Administrativos',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón de configuración con indicadores
                  Row(
                    children: [
                      // Botón de configuración
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => _showSettingsDialog(context),
                          icon: const Icon(Icons.settings, size: 20, color: Colors.white),
                          tooltip: AppLocalizations.of(context)?.get('settings') ?? 'Configuración',
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Indicadores de configuración actual
                      ValueListenableBuilder<bool>(
                        valueListenable: isDarkMode,
                        builder: (context, darkMode, _) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  darkMode ? Icons.dark_mode : Icons.light_mode,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                ValueListenableBuilder<Locale>(
                                  valueListenable: appLocale,
                                  builder: (context, locale, _) {
                                    return Text(
                                      locale.languageCode.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Botón FAQ
            ListTile(
              leading: Icon(
                Icons.help_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                AppLocalizations.of(context)?.get('faq') ?? 'FAQ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FAQScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            // Lista de procesos
            Expanded(
              child: ListView.builder(
                itemCount: processList.length,
                itemBuilder: (context, index) {
                  final process = processList[index];
                  return ListTile(
                    title: Text(process.title),
                    onTap: () {
                      Navigator.pop(context);
                      _pageController.jumpToPage(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: processList.length,
        physics: const PageScrollPhysics(), // Smooth page scrolling
        pageSnapping: true, // Snap to pages
        onPageChanged: (page) {
          // Solo actualizar el notifier, sin setState
          _currentPageNotifier.value = page;
        },
        itemBuilder: (context, index) {
          return ProcessItems(
            processStudy: processList[index],
            indexPage: index,
            onProcessDeleted: _handleProcessDeleted,
          );
        },
      ),
      bottomNavigationBar: _buildSmartBottomNavigation(context, processList, currentPage),
    );
      }
    );
  }

  Widget _buildSmartBottomNavigation(
      BuildContext context, List<ProcessStudy> processList, int currentPage) {
    const int maxVisibleDots = 7; // Máximo número de puntos visibles
    const int groupSize = 10; // Agrupar cada 10 páginas

    // Si hay pocos elementos, usar el dock original
    if (processList.length <= maxVisibleDots) {
      return _buildOriginalDock(context, processList, currentPage);
    }

    // Si hay muchos elementos, usar navegación inteligente
    return _buildSmartDock(context, processList, maxVisibleDots, groupSize, currentPage);
  }

  Widget _buildOriginalDock(
      BuildContext context, List<ProcessStudy> processList, int currentPage) {
    return Container(
      color: Theme.of(context).colorScheme.primary, // Color dinámico del tema
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final minDotSize = 6.0;
          final maxDotSize = 16.0;
          final dotSpacing = 8.0;
          final totalSpacing = dotSpacing * (processList.length - 1);
          final buttonWidth = 96.0; // Espacio para botones de navegación

          // Calcular tamaño de punto adaptativo
          double dotSize = maxDotSize;
          final requiredWidth =
              processList.length * maxDotSize + totalSpacing + buttonWidth;

          if (requiredWidth > maxWidth) {
            dotSize =
                ((maxWidth - buttonWidth - totalSpacing) / processList.length)
                    .clamp(minDotSize, maxDotSize);
          }

          const Color dockDotActive = Colors.white;
          const Color dockDotInactive = Color(0x80FFFFFF); // Blanco semi-transparente
          const Color dockArrow = Colors.white;

          // Para pantallas muy pequeñas, usar una versión ultra compacta
          if (maxWidth < 300) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: dockArrow, size: 18),
                    onPressed: currentPage > 0
                        ? () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease)
                        : null,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${currentPage + 1}/${processList.length}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: dockArrow, size: 18),
                    onPressed: currentPage < processList.length - 1
                        ? () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease)
                        : null,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: dockArrow, size: 20),
                    onPressed: currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                  ),
                  ...List.generate(processList.length, (index) {
                    final isActive = currentPage == index;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: dotSpacing / 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isActive ? dotSize * 1.2 : dotSize,
                          height: isActive ? dotSize * 1.2 : dotSize,
                          decoration: BoxDecoration(
                            color: isActive ? dockDotActive : dockDotInactive,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, color: dockArrow, size: 20),
                    onPressed: currentPage < processList.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmartDock(BuildContext context, List<ProcessStudy> processList,
      int maxVisibleDots, int groupSize, int currentPage) {
    const Color dockDotActive = Colors.white;
    const Color dockDotInactive = Color(0x80FFFFFF); // Blanco semi-transparente
    const Color dockArrow = Colors.white;
    final Color dockBg = Theme.of(context).colorScheme.primary; // Color dinámico del tema

    // Calcular grupo actual
    final currentGroup = currentPage ~/ groupSize;
    final totalGroups = (processList.length / groupSize).ceil();

    // Determinar qué puntos mostrar (se recalculará en _buildResponsiveNavigation)
    List<int> visibleIndexes = _calculateVisibleIndexes(
        processList.length, currentPage, maxVisibleDots);

    return Container(
      color: dockBg,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Información de página actual
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '${currentPage + 1} / ${processList.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Navegación principal responsive
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              return _buildResponsiveNavigation(
                  availableWidth,
                  visibleIndexes,
                  dockArrow,
                  dockDotActive,
                  dockDotInactive,
                  processList.length,
                  currentPage);
            },
          ),

          // Navegación rápida por grupos (si hay muchos grupos)
          if (totalGroups > 5) ...[
            const SizedBox(height: 8),
            _buildGroupNavigation(totalGroups, currentGroup, dockDotActive,
                dockDotInactive, groupSize, currentPage),
          ],
        ],
      ),
    );
  }

  List<int> _calculateVisibleIndexes(
      int totalItems, int currentPage, int maxVisible) {
    if (totalItems <= maxVisible) {
      return List.generate(totalItems, (index) => index);
    }

    List<int> visible = [];

    // Siempre mostrar la primera página
    visible.add(0);

    // Determinar el rango alrededor de la página actual
    int start =
        (currentPage - (maxVisible ~/ 2)).clamp(1, totalItems - maxVisible + 1);
    int end = (start + maxVisible - 3).clamp(2, totalItems - 2);

    // Agregar "..." si hay un salto
    if (start > 1) {
      visible.add(-1); // -1 representa "..."
    }

    // Agregar páginas en el rango
    for (int i = start; i <= end; i++) {
      if (i != 0 && i != totalItems - 1) {
        visible.add(i);
      }
    }

    // Agregar "..." si hay un salto al final
    if (end < totalItems - 2) {
      visible.add(-1);
    }

    // Siempre mostrar la última página
    if (totalItems > 1) {
      visible.add(totalItems - 1);
    }

    return visible;
  }

  Widget _buildGroupNavigation(int totalGroups, int currentGroup,
      Color activeColor, Color inactiveColor, int groupSize, int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Grupos: ',
            style: TextStyle(color: Colors.white70, fontSize: 10)),
        ...List.generate(totalGroups.clamp(0, 10), (groupIndex) {
          final isActiveGroup = currentGroup == groupIndex;
          return GestureDetector(
            onTap: () {
              final targetPage = groupIndex * groupSize;
              _pageController.animateToPage(
                targetPage.clamp(0, totalGroups * groupSize - 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: isActiveGroup ? activeColor : inactiveColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${groupIndex + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight:
                      isActiveGroup ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }),
        if (totalGroups > 10)
          const Text('...',
              style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  Widget _buildResponsiveNavigation(
    double availableWidth,
    List<int> visibleIndexes,
    Color dockArrow,
    Color dockDotActive,
    Color dockDotInactive,
    int totalPages,
    int currentPage,
  ) {
    // Calcular cuántos elementos podemos mostrar según el ancho
    const double buttonWidth = 48.0; // Ancho aproximado de IconButton
    const double pageButtonWidth = 32.0; // Ancho de botones de página

    // Botones fijos: primera, anterior, siguiente, última = 4 * 48 = 192
    const double fixedButtonsWidth = 4 * buttonWidth;
    final double availableForPages =
        availableWidth - fixedButtonsWidth - 32; // 32 para padding

    // Calcular máximo de botones de página que caben
    int maxPageButtons = (availableForPages / pageButtonWidth).floor();
    maxPageButtons = maxPageButtons.clamp(1, 7); // Mínimo 1, máximo 7

    // Recalcular índices visibles según el espacio disponible
    final adjustedVisibleIndexes =
        _calculateVisibleIndexes(totalPages, currentPage, maxPageButtons);

    // Para pantallas muy pequeñas, usar navegación compacta
    if (availableWidth < 400) {
      return _buildCompactNavigation(
          dockArrow, dockDotActive, dockDotInactive, totalPages, currentPage);
    }

    // Navegación normal
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón primera página
          IconButton(
            icon: Icon(Icons.first_page, color: dockArrow, size: 20),
            onPressed: currentPage > 0
                ? () => _pageController.animateToPage(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                : null,
          ),

          // Botón página anterior
          IconButton(
            icon: Icon(Icons.chevron_left, color: dockArrow, size: 20),
            onPressed: currentPage > 0
                ? () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                : null,
          ),

          // Puntos visibles
          ...adjustedVisibleIndexes.map((index) {
            if (index == -1) {
              // Mostrar "..." para indicar páginas ocultas
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                child: const Text(
                  '...',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              );
            }

            final isActive = currentPage == index;
            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 28 : 24,
                  height: isActive ? 28 : 24,
                  decoration: BoxDecoration(
                    color: isActive ? dockDotActive : dockDotInactive,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isActive ? 10 : 9,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),

          // Botón página siguiente
          IconButton(
            icon: Icon(Icons.chevron_right, color: dockArrow, size: 20),
            onPressed: currentPage < totalPages - 1
                ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                : null,
          ),

          // Botón última página
          IconButton(
            icon: Icon(Icons.last_page, color: dockArrow, size: 20),
            onPressed: currentPage < totalPages - 1
                ? () => _pageController.animateToPage(totalPages - 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactNavigation(Color dockArrow, Color dockDotActive,
      Color dockDotInactive, int totalPages, int currentPage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón anterior
        IconButton(
          icon: Icon(Icons.chevron_left, color: dockArrow, size: 18),
          onPressed: currentPage > 0
              ? () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease)
              : null,
        ),

        // Indicador de página actual (más compacto)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: dockDotActive,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            '${currentPage + 1}/${totalPages}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Botón siguiente
        IconButton(
          icon: Icon(Icons.chevron_right, color: dockArrow, size: 18),
          onPressed: currentPage < totalPages - 1
              ? () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease)
              : null,
        ),
      ],
    );
  }

  void _showSearchDialog(
      BuildContext context, List<ProcessStudy> processList) {
    final TextEditingController controller = TextEditingController();
    List<ProcessStudy> filteredProcesses = List.from(processList);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)?.get('searchProcess') ?? 'Buscar proceso'),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.get('searchHint') ?? 'Buscar por título o descripción',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                controller.clear();
                                setStateDialog(() {
                                  filteredProcesses = List.from(processList);
                                });
                              },
                            )
                          : null,
                    ),
                  onChanged: (value) {
                    setStateDialog(() {
                      if (value.isEmpty) {
                        filteredProcesses = List.from(processList);
                      } else {
                        final searchLower = value.toLowerCase();
                        filteredProcesses = processList.where((process) {
                          // Buscar en título y descripción del proceso
                          if (process.title.toLowerCase().contains(searchLower) ||
                              process.description.toLowerCase().contains(searchLower)) {
                            return true;
                          }
                          
                          // Buscar en los stages (nombre y descripción de cada etapa)
                          for (var stage in process.processStage) {
                            if (stage.stage.toLowerCase().contains(searchLower) ||
                                stage.description.toLowerCase().contains(searchLower)) {
                              return true;
                            }
                          }
                          
                          return false;
                        }).toList();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Lista de procesos filtrados con altura flexible
                Flexible(
                  child: Container(
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: filteredProcesses.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)?.get('noResults') ?? 'No se encontraron resultados',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                      : ListView.builder(
                          itemCount: filteredProcesses.length,
                          itemBuilder: (context, index) {
                            final process = filteredProcesses[index];
                            final processIndex = processList.indexOf(process);
                            final isCurrentPage = processIndex == _currentPageNotifier.value;

                            return ListTile(
                              dense: true,
                              selected: isCurrentPage,
                              leading: CircleAvatar(
                                radius: 16,
                                child: Text(
                                  '${processIndex + 1}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              title: Text(
                                process.title,
                                style: TextStyle(
                                  fontWeight: isCurrentPage
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                process.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _pageController.animateToPage(
                                  processIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                            );
                          },
                        ),
                  ),
                ),
              ],
            ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)?.get('close') ?? 'Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(context)?.get('settings') ?? 'Configuración',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Sección de Tema
            Text(
              AppLocalizations.of(context)?.get('theme') ?? 'Tema',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<bool>(
              valueListenable: isDarkMode,
              builder: (context, darkMode, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<bool>(
                        title: Row(
                          children: [
                            Icon(Icons.light_mode, 
                                color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('lightMode') ?? 'Modo Claro',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: false,
                        groupValue: darkMode,
                        onChanged: (value) {
                          if (value != null) {
                            isDarkMode.value = value;
                            SettingsManager.saveTheme(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<bool>(
                        title: Row(
                          children: [
                            Icon(Icons.dark_mode,
                                color: Theme.of(context).colorScheme.onSurface),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('darkMode') ?? 'Modo Oscuro',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: true,
                        groupValue: darkMode,
                        onChanged: (value) {
                          if (value != null) {
                            isDarkMode.value = value;
                            SettingsManager.saveTheme(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sección de Idioma
            Text(
              (AppLocalizations.of(context)?.get('language') ?? 'Idioma:').replaceAll(':', ''),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)?.get('english') ?? 'English',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    value: 'en',
                    groupValue: appLocale.value.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          appLocale.value = Locale(value);
                          _processListFuture = null;
                          _currentLanguage = null;
                          _currentPageNotifier.value = 0;
                        });
                        SettingsManager.saveLocale(value);
                        
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        });
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<String>(
                    title: Row(
                      children: [
                        const Text('🇪🇸', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)?.get('spanish') ?? 'Español',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    value: 'es',
                    groupValue: appLocale.value.languageCode,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          appLocale.value = Locale(value);
                          _processListFuture = null;
                          _currentLanguage = null;
                          _currentPageNotifier.value = 0;
                        });
                        SettingsManager.saveLocale(value);
                        
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        });
                      }
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // Nueva Sección de Estilo de Viñetas
            Text(
              AppLocalizations.of(context)?.get('chooseIcon') ?? 'Elige viñeta:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: flagStyle,
              builder: (context, currentFlagStyle, _) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            const Icon(Icons.flag_rounded, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('flagStyle') ?? 'Banderas',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: 'flags',
                        groupValue: currentFlagStyle,
                        onChanged: (value) {
                          if (value != null) {
                            flagStyle.value = value;
                            SettingsManager.saveFlagStyle(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('numberStyle') ?? 'Números',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: 'numbers',
                        groupValue: currentFlagStyle,
                        onChanged: (value) {
                          if (value != null) {
                            flagStyle.value = value;
                            SettingsManager.saveFlagStyle(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.circle, size: 20, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('dotStyle') ?? 'Puntos',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: 'dots',
                        groupValue: currentFlagStyle,
                        onChanged: (value) {
                          if (value != null) {
                            flagStyle.value = value;
                            SettingsManager.saveFlagStyle(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'S1',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('codeStyle') ?? 'Códigos',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: 'codes',
                        groupValue: currentFlagStyle,
                        onChanged: (value) {
                          if (value != null) {
                            flagStyle.value = value;
                            SettingsManager.saveFlagStyle(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.star, size: 20, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppLocalizations.of(context)?.get('starStyle') ?? 'Estrellas',
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        value: 'stars',
                        groupValue: currentFlagStyle,
                        onChanged: (value) {
                          if (value != null) {
                            flagStyle.value = value;
                            SettingsManager.saveFlagStyle(value);
                          }
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sección de Gestión de Datos
            Text(
              AppLocalizations.of(context)?.get('dataManagement') ?? 'Gestión de Datos',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: Text(
                      AppLocalizations.of(context)?.get('exportData') ?? 'Exportar Datos',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)?.get('exportDescription') ?? 'Exportar registros eliminables a un archivo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      try {
                        final success = await SettingsManager.exportData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success 
                                  ? (AppLocalizations.of(context)?.get('exportSuccess') ?? 'Datos exportados exitosamente')
                                  : (AppLocalizations.of(context)?.get('exportError') ?? 'Error al exportar datos'),
                              ),
                              backgroundColor: success 
                                ? Colors.green 
                                : Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.get('exportError') ?? 'Error al exportar datos'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.upload),
                    title: Text(
                      AppLocalizations.of(context)?.get('importData') ?? 'Importar Datos',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      AppLocalizations.of(context)?.get('importDescription') ?? 'Importar datos desde un archivo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      try {
                        final success = await SettingsManager.importData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success 
                                  ? (AppLocalizations.of(context)?.get('importSuccess') ?? 'Datos importados exitosamente')
                                  : (AppLocalizations.of(context)?.get('importError') ?? 'Error al importar datos'),
                              ),
                              backgroundColor: success 
                                ? Colors.green 
                                : Colors.red,
                            ),
                          );
                          if (success) {
                            // Reload process data and close dialog
                            setState(() {
                              _processListFuture = null;
                              _currentLanguage = null;
                            });
                            Navigator.pop(context);
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)?.get('importError') ?? 'Error al importar datos'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.get('close') ?? 'Cerrar'),
          ),
        ],
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
