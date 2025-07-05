import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/Article.dart';
import '../services/api_service.dart';
import '../databases/Database_helper.dart';

class ArticleProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  List<Article> _allArticles = [];
  List<Article> _savedArticles = [];

  bool _isLoading = false;
  String? _error;

  List<Article> get allArticles => _allArticles;
  List<Article> get savedArticles => _savedArticles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ArticleProvider() {
    loadArticlesWithCache();
  }

  Future<bool> hasInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> loadArticlesWithCache() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    bool connected = await hasInternetConnection();

    // Charger les articles déjà sauvegardés localement
    _savedArticles = await DatabaseHelper.instance.getArticles();

    if (!connected) {
      if (_savedArticles.isEmpty) {
        _error = "Pas de connexion internet et aucun article local disponible.";
      }
      _allArticles = _savedArticles;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Si connecté : charger depuis l’API et marquer les articles sauvegardés
    try {
      final ids = await apiService.fetchTopStoryIds();
      List<Article> loaded = [];

      for (var id in ids.take(30)) { // Limite si besoin
        try {
          Article article = await apiService.fetchArticleById(id);
          // Vérifier s’il est dans les sauvegardés
          article.isFavorite = _savedArticles.any((a) => a.id == id && a.isFavorite);
          loaded.add(article);
        } catch (e) {
          debugPrint("Erreur chargement article $id : $e");
        }
      }

      _allArticles = loaded;
    } catch (e) {
      _error = 'Erreur de chargement : $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveArticle(Article article) async {
    await DatabaseHelper.instance.insertArticle(article);
    if (!_savedArticles.any((a) => a.id == article.id)) {
      _savedArticles.add(article);
    }
    notifyListeners();
  }

  Future<void> removeArticle(int articleId) async {
    await DatabaseHelper.instance.deleteArticle(articleId);
    _savedArticles.removeWhere((a) => a.id == articleId);
    notifyListeners();
  }

  Future<bool> isArticleSaved(int id) async {
    return _savedArticles.any((a) => a.id == id);
  }

  void toggleFavorite(Article article) async {
    article.isFavorite = !article.isFavorite;
    await DatabaseHelper.instance.insertArticle(article);

    // Mettre à jour la version locale si elle existe
    final index = _savedArticles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _savedArticles[index] = article;
    }

    notifyListeners();
  }

  List<Article> get favoriteArticles =>
      _allArticles.where((article) => article.isFavorite).toList();
}
