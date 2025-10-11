import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:admin_processes/data/process_list.dart';
import 'package:admin_processes/view/process_items.dart';
import 'package:admin_processes/l10n/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
  int _currentPage = 0;




final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
void main() => runApp(AdminProcessApp());

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
            appBarTheme: const AppBarTheme(
                backgroundColor: Color.fromRGBO(34, 71, 237, 1),
                foregroundColor: Colors.white),
            checkboxTheme: CheckboxThemeData(
              fillColor: WidgetStateProperty.all(const Color.fromRGBO(34, 71, 237, 1)),side: const BorderSide(color: Colors.white),
            ),
            expansionTileTheme: const ExpansionTileThemeData(iconColor: Colors.white, collapsedIconColor: Colors.white ),
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processList = getProcessList(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.get('processTitle') ?? 'Procesos Administrativos'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: appLocale.value.languageCode,
              icon: const Icon(Icons.language, color: Colors.white),
              dropdownColor: const Color(0xFF222831),
              items: [
                DropdownMenuItem(value: 'en', child: Text(AppLocalizations.of(context)?.get('english') ?? 'English', style: const TextStyle(color: Colors.white))),
                DropdownMenuItem(value: 'es', child: Text(AppLocalizations.of(context)?.get('spanish') ?? 'Español', style: const TextStyle(color: Colors.white))),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    appLocale.value = Locale(value);
                  });
                }
              },
            ),
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
                  applicationName: AppLocalizations.of(context)?.get('processTitle') ?? 'Procesos Administrativos',
                  applicationLegalese: '2025 MIT License',
                  children: [
                    Text(AppLocalizations.of(context)?.get('description') ?? ''),
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
              child: Text(AppLocalizations.of(context)?.get('processTitle') ?? 'Procesos Administrativos', style: const TextStyle(fontSize: 20)),
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
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          return ProcessItems(indexPage: index);
        },
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF222831),
        child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth;
              final minDotSize = 8.0;
              final maxDotSize = 16.0;
              final dotSpacing = 12.0;
              final totalSpacing = dotSpacing * (processList.length - 1);
              double dotSize = maxDotSize;
              if (processList.length * maxDotSize + totalSpacing > maxWidth - 96) {
                dotSize = ((maxWidth - 96 - totalSpacing) / processList.length).clamp(minDotSize, maxDotSize);
              }
              // dockBg eliminado porque no se usa
              final Color dockDotActive = const Color(0xFF00ADB5);
              final Color dockDotInactive = const Color(0xFF393E46);
              final Color dockArrow = Colors.white;
              return Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: dotSpacing,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: dockArrow),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: isActive ? dotSize * 1.5 : dotSize,
                        height: isActive ? dotSize * 1.5 : dotSize,
                        decoration: BoxDecoration(
                          color: isActive ? dockDotActive : dockDotInactive,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.arrow_forward, color: dockArrow),
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
              );
            },
          ),
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
