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
      home: Scaffold(
        appBar: AppBar(title: const Text('Admin Processes')),
        body: PageView(
          children: [
            for(int i=0;i<processList.length;i++)
              ProcessItems(indexPage: i)
          ],
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
      };
}