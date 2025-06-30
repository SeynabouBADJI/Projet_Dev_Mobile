import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/article.dart';

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
        by TEXT NOT NULL,
        time INTEGER,
        descendants INTEGER,
        url TEXT,
        kids TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
  }

  Future<void> insertArticle(Article article) async {
    final db = await instance.database;
    await db.insert(
      'articles',
      article.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Article sauvegardé : ${article.toMap()}");

  }

  Future<List<Article>> getArticles() async {
    final db = await instance.database;
    final result = await db.query('articles');
    return result.map((map) => Article.fromMap(map)).toList();
  }

  Future<void> deleteAllArticles() async {
    final db = await instance.database;
    await db.delete('articles');
  }

  Future<void> cleanOldArticles(Future<bool> Function(int id) isAvailableOnApi) async {
  final db = await database;
  final articles = await getArticles();

  for (var article in articles) {
    if (!article.isFavorite) {
      final stillExists = await isAvailableOnApi(article.id);
      if (!stillExists) {
        await db.delete('articles', where: 'id = ?', whereArgs: [article.id]);
      }
    }
  }
}

}

