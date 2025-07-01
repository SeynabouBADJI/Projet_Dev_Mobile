// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'screens/home_screen.dart';
// import 'package:path/path.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//    // Supprimer la base existante
//   final dbPath = await getDatabasesPath();
//   final path = join(dbPath, 'articles.db');
//   await deleteDatabase(path);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Hacker News',
//       theme: ThemeData(
//         primarySwatch: Colors.orange,
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hacker_news_app/providers/ArticleProvider.dart';
import 'package:hacker_news_app/providers/CommentProvider.dart'; // Ajoute ce provider si tu l'as créé
import 'package:hacker_news_app/screens/Home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ArticleProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        // Ajoute d'autres providers ici si besoin
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

