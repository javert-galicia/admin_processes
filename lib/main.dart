import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';
import 'package:admin_processes/view/process_items.dart';
import 'package:admin_processes/view/add_process_screen.dart';
import 'package:admin_processes/l10n/localization.dart';
import 'package:admin_processes/db/process_data_service.dart';
import 'package:admin_processes/db/database_platform.dart';
import 'package:admin_processes/model/process_study.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

int _currentPage = 0;

final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

void main() {
  // Initialize database platform before running the app
  DatabasePlatform.initialize();
  runApp(AdminProcessApp());
}

class AdminProcessApp extends StatelessWidget {
  AdminProcessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          scrollBehavior: AppScrollBehavior(),
          theme: ThemeData(
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
              side: const BorderSide(color: Color(0xFF1565C0), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
              backgroundColor: Color(0xFFF8F9FA),
              surfaceTintColor: Colors.transparent,
            ),
          ),
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

            // Adjust current page if it's beyond the available processes
            if (_currentPage >= processList.length && processList.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _currentPage = processList.length - 1;
                  _pageController.jumpToPage(_currentPage);
                });
              });
            } else if (processList.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _currentPage = 0;
                });
              });
            }

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
    // Ensure current page is within bounds
    if (_currentPage >= processList.length) {
      _currentPage = 0;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.get('processTitle') ??
            'Procesos Administrativos'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: appLocale.value.languageCode,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: const Color(0xFF0277BD), // Azul secundario
              items: [
                DropdownMenuItem(
                    value: 'en',
                    child: Text(
                        AppLocalizations.of(context)?.get('english') ??
                            'English',
                        style: const TextStyle(color: Colors.white))),
                DropdownMenuItem(
                    value: 'es',
                    child: Text(
                        AppLocalizations.of(context)?.get('spanish') ??
                            'Español',
                        style: const TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    appLocale.value = Locale(value);
                    // Invalidate cache when language changes
                    _processListFuture = null;
                    _currentLanguage = null;
                    // Reset to first page when changing language
                    _currentPage = 0;
                  });

                  // Navigate to first page after state update
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
            ),
          ),
          IconButton(
            onPressed: () => _showGoToPageDialog(context, processList),
            icon: const Icon(Icons.pages),
            tooltip: 'Ir a página',
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
                  applicationVersion: '1.0.1.0',
                  applicationName:
                      AppLocalizations.of(context)?.get('processTitle') ??
                          'Procesos Administrativos',
                  applicationLegalese: '2025 MIT License',
                  children: [
                    Text(
                        AppLocalizations.of(context)?.get('description') ?? ''),
                    Text(AppLocalizations.of(context)?.get('aboutInfo') ?? ''),
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
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0), // Azul corporativo
              ),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                    AppLocalizations.of(context)?.get('processTitle') ??
                        'Procesos Administrativos',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                    )),
              ),
            ),
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
          if (mounted) {
            // Check if widget is still mounted
            setState(() {
              _currentPage = page;
            });
          }
        },
        itemBuilder: (context, index) {
          return ProcessItems(
            processStudy: processList[index],
            indexPage: index,
            onProcessDeleted: _handleProcessDeleted,
          );
        },
      ),
      bottomNavigationBar: _buildSmartBottomNavigation(context, processList),
    );
  }

  Widget _buildSmartBottomNavigation(
      BuildContext context, List<ProcessStudy> processList) {
    const int maxVisibleDots = 7; // Máximo número de puntos visibles
    const int groupSize = 10; // Agrupar cada 10 páginas

    // Si hay pocos elementos, usar el dock original
    if (processList.length <= maxVisibleDots) {
      return _buildOriginalDock(context, processList);
    }

    // Si hay muchos elementos, usar navegación inteligente
    return _buildSmartDock(context, processList, maxVisibleDots, groupSize);
  }

  Widget _buildOriginalDock(
      BuildContext context, List<ProcessStudy> processList) {
    return Container(
      color: const Color(0xFF1565C0), // Azul corporativo
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
                    onPressed: _currentPage > 0
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
                      '${_currentPage + 1}/${processList.length}',
                      style: const TextStyle(
                          color: Color(0xFF1565C0), // Azul corporativo
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: dockArrow, size: 18),
                    onPressed: _currentPage < processList.length - 1
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
                    onPressed: _currentPage > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                  ),
                  ...List.generate(processList.length, (index) {
                    final isActive = _currentPage == index;
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
                    onPressed: _currentPage < processList.length - 1
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
      int maxVisibleDots, int groupSize) {
    const Color dockDotActive = Colors.white;
    const Color dockDotInactive = Color(0x80FFFFFF); // Blanco semi-transparente
    const Color dockArrow = Colors.white;
    const Color dockBg = Color(0xFF1565C0); // Azul corporativo

    // Calcular grupo actual
    final currentGroup = _currentPage ~/ groupSize;
    final totalGroups = (processList.length / groupSize).ceil();

    // Determinar qué puntos mostrar (se recalculará en _buildResponsiveNavigation)
    List<int> visibleIndexes = _calculateVisibleIndexes(
        processList.length, _currentPage, maxVisibleDots);

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
              '${_currentPage + 1} / ${processList.length}',
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
                  processList.length);
            },
          ),

          // Navegación rápida por grupos (si hay muchos grupos)
          if (totalGroups > 5) ...[
            const SizedBox(height: 8),
            _buildGroupNavigation(totalGroups, currentGroup, dockDotActive,
                dockDotInactive, groupSize),
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
      Color activeColor, Color inactiveColor, int groupSize) {
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
        _calculateVisibleIndexes(totalPages, _currentPage, maxPageButtons);

    // Para pantallas muy pequeñas, usar navegación compacta
    if (availableWidth < 400) {
      return _buildCompactNavigation(
          dockArrow, dockDotActive, dockDotInactive, totalPages);
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
            onPressed: _currentPage > 0
                ? () => _pageController.animateToPage(0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                : null,
          ),

          // Botón página anterior
          IconButton(
            icon: Icon(Icons.chevron_left, color: dockArrow, size: 20),
            onPressed: _currentPage > 0
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

            final isActive = _currentPage == index;
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
            onPressed: _currentPage < totalPages - 1
                ? () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease)
                : null,
          ),

          // Botón última página
          IconButton(
            icon: Icon(Icons.last_page, color: dockArrow, size: 20),
            onPressed: _currentPage < totalPages - 1
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
      Color dockDotInactive, int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Botón anterior
        IconButton(
          icon: Icon(Icons.chevron_left, color: dockArrow, size: 18),
          onPressed: _currentPage > 0
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
            '${_currentPage + 1}/${totalPages}',
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
          onPressed: _currentPage < totalPages - 1
              ? () => _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease)
              : null,
        ),
      ],
    );
  }

  void _showGoToPageDialog(
      BuildContext context, List<ProcessStudy> processList) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir a página'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de página (1-${processList.length})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Lista de procesos para selección rápida
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: processList.length,
                itemBuilder: (context, index) {
                  final process = processList[index];
                  final isCurrentPage = index == _currentPage;

                  return ListTile(
                    dense: true,
                    selected: isCurrentPage,
                    title: Text(
                      '${index + 1}. ${process.title}',
                      style: TextStyle(
                        fontWeight:
                            isCurrentPage ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      process.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final pageNum = int.tryParse(controller.text);
              if (pageNum != null &&
                  pageNum > 0 &&
                  pageNum <= processList.length) {
                Navigator.pop(context);
                _pageController.animateToPage(
                  pageNum - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            child: const Text('Ir'),
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
