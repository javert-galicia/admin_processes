import 'dart:ui';

import 'package:admin_processes/data/process_list.dart';
import 'package:flutter/material.dart';
import 'package:admin_processes/view/process_items.dart';

void main() => runApp(const AdminProcessApp());

class AdminProcessApp extends StatelessWidget {
  const AdminProcessApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      home: const HomeTree(),
    );
  }
}

class HomeTree extends StatelessWidget {
  const HomeTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesos Administrativos'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => const AboutDialog(
                          applicationVersion: '1.0',
                          applicationName: 'Procesos Administrativos',
                          applicationLegalese: '2025 Copyright Javert Galicia',
                          children: [
                            Text(
                                'For more information: https://jgalicia.com')
                          ],
                        ));
              },
              icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: PageView.builder(
        itemBuilder: (context, index) =>
            ProcessItems(indexPage: index % processList.length),
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
