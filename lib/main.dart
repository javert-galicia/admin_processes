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
      theme: ThemeData(useMaterial3: true),
      home:  const HomeTree(),
    );
  }
}

class HomeTree extends StatelessWidget {
   const HomeTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Processes'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => const AboutDialog(
                          applicationVersion: '1.0',
                          applicationName: 'Admin Processes',
                          applicationLegalese: 'MIT',
                          children: [
                            Text(
                                'For more information visit https://admin.jgalicia.com')
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
      };
}
