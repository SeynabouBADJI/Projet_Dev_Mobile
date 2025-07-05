import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/Article.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('articles.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY,
        title TEXT,
        by TEXT,
        url TEXT,
        kids TEXT,
        descendants INTEGER,
        isFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Insérer ou mettre à jour un article
  Future<void> insertArticle(Article article) async {
    final db = await instance.database;
    await db.insert(
      'articles',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupérer un article par id localement
  Future<Article?> getArticleById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Récupérer tous les articles sauvegardés
  Future<List<Article>> getArticles() async {
    final db = await instance.database;
    final result = await db.query('articles');
    return result.map((map) => Article.fromMap(map)).toList();
  }

  // Récupérer uniquement les favoris
  Future<List<Article>> getFavoriteArticles() async {
    final db = await instance.database;
    final result = await db.query('articles', where: 'isFavorite = ?', whereArgs: [1]);
    return result.map((map) => Article.fromMap(map)).toList();
  }


  Future<int> deleteArticle(int id) async {
  final db = await database;
  return await db.delete(
    'articles', // Nom de ta table SQLite
    where: 'id = ?',
    whereArgs: [id],
  );
}

}
