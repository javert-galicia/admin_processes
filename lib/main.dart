import 'package:flutter/material.dart';
import 'package:admin_processes/process_items.dart';

void main() => runApp(const AdminProcessApp());

class AdminProcessApp extends StatelessWidget {
  const AdminProcessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Admin Processes')),
        body: const ProcessItems(
          indexPage: 0,
        ),
      ),
    );
  }
}
