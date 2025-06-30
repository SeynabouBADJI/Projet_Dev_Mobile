import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'screens/home_screen.dart';
import 'package:path/path.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   // Supprimer la base existante
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'articles.db');
  await deleteDatabase(path);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
