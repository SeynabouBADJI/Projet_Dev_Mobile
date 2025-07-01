
// import 'package:flutter/foundation.dart';
// import '../models/article.dart';
// import '../services/api_service.dart';
// import '../databases/Database_helper.dart';

// class ArticleProvider extends ChangeNotifier {
//   final ApiService apiService = ApiService();

//   List<Article> _articles = [];
//   bool _isLoading = false;
//   String? _error;

//   List<Article> get articles => _articles;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> loadArticlesWithCache() async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final ids = await apiService.fetchTopStoryIds();
//       List<Article> loadedArticles = [];

//       for (var id in ids) {
//         Article? localArticle = await DatabaseHelper.instance.getArticleById(id);
//         if (localArticle != null) {
//           loadedArticles.add(localArticle);
//         } else {
//           try {
//             Article fetchedArticle = await apiService.fetchArticleById(id);
//             await DatabaseHelper.instance.insertArticle(fetchedArticle);
//             loadedArticles.add(fetchedArticle);
//           } catch (e) {
//             debugPrint("Erreur chargement article $id depuis API : $e");
//           }
//         }
//       }

//       _articles = loadedArticles;
//       _error = null;
//     } catch (e) {
//       _error = e.toString();
//     }

//     _isLoading = false;
//     notifyListeners();
//   }

//   Future<void> toggleFavorite(Article article) async {
//     article.isFavorite = article.isFavorite == 1 ? 0 : 1;
//     await DatabaseHelper.instance.insertArticle(article);
//     notifyListeners();
//   }

//   Future<void> saveArticle(Article article) async {
//     await DatabaseHelper.instance.insertArticle(article);
//     // Recharge la liste localement si besoin
//     await loadArticlesWithCache();
//   }

//   Future<void> cleanupOldArticles() async {
//     final allArticles = await DatabaseHelper.instance.getArticles();

//     for (var article in allArticles) {
//       if (article.isFavorite == 1) continue;

//       try {
//         await apiService.fetchArticleById(article.id);
//       } catch (_) {
//         await DatabaseHelper.instance.deleteArticle(article.id);
//       }
//     }
//     // Recharge la liste après nettoyage
//     await loadArticlesWithCache();
//   }
// }
import 'package:flutter/material.dart';
import '../databases/Database_helper.dart';
import '../models/Article.dart';
import '../services/Api_service.dart';

class ArticleProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _error;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ArticleProvider() {
    loadArticlesWithCache();
  }

  Future<void> loadArticlesWithCache() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ids = await apiService.fetchTopStoryIds();
      List<Article> articlesLoaded = [];

      for (var id in ids) {
        Article? localArticle = await DatabaseHelper.instance.getArticleById(id);
        if (localArticle != null) {
          articlesLoaded.add(localArticle);
        } else {
          try {
            Article fetchedArticle = await apiService.fetchArticleById(id);
            await DatabaseHelper.instance.insertArticle(fetchedArticle);
            articlesLoaded.add(fetchedArticle);
          } catch (e) {
            debugPrint("Erreur chargement article $id : $e");
          }
        }
      }

      _articles = articlesLoaded;
    } catch (e) {
      _error = 'Erreur de chargement : $e';
    }

    _isLoading = false;
    notifyListeners();
  }

 Future<void> toggleFavorite(Article article) async {
  article.isFavorite = !article.isFavorite; // inverser le booléen
  await DatabaseHelper.instance.insertArticle(article);
  notifyListeners();
}


  Future<void> saveArticle(Article article) async {
    await DatabaseHelper.instance.insertArticle(article);
    if (!_articles.any((a) => a.id == article.id)) {
      _articles.add(article);
      notifyListeners();
    }
  }

  Future<void> cleanupOldArticles() async {
    List<Article> toRemove = [];

    for (var article in _articles) {
      if (article.isFavorite) continue; // c’est bool donc pas == 1
      try {
        await apiService.fetchArticleById(article.id);
      } catch (_) {
        await DatabaseHelper.instance.deleteArticle(article.id);
        toRemove.add(article);
      }
    }

    if (toRemove.isNotEmpty) {
      _articles.removeWhere((a) => toRemove.contains(a));
      notifyListeners();
    }
  }

  List<Article> get favoriteArticles =>
      _articles.where((article) => article.isFavorite).toList();
}
