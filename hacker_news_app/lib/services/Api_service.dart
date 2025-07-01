import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Article.dart';
import '../models/Comment.dart';
import '../databases/Database_helper.dart';

class ApiService {
  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';

  // Obtenir les IDs des meilleurs articles
  Future<List<int>> fetchTopStoryIds() async {
    final response = await http.get(Uri.parse('$baseUrl/topstories.json'));

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>().take(20).toList(); // Limité à 20 articles
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

  // Récupérer un article depuis l’API
  Future<Article> fetchArticleById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/item/$id.json'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Article.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement de l’article $id');
    }
  }

  // Vérifier si un article est encore disponible en ligne
  Future<bool> isArticleAvailable(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/item/$id.json'));
    return response.statusCode == 200 && response.body != 'null';
  }

  // Récupérer un commentaire depuis l’API
  Future<Comment> fetchCommentById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/item/$id.json'));

    if (response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors du chargement du commentaire $id');
    }
  }

  // Article avec cache local
  Future<Article> fetchArticleWithCache(int id) async {
    // Vérifier localement
    final local = await DatabaseHelper.instance.getArticleById(id);
    if (local != null) return local;

    // Sinon, fetch API
    final apiArticle = await fetchArticleById(id);
    await DatabaseHelper.instance.insertArticle(apiArticle);
    return apiArticle;
  }

  // Nettoyer les anciens articles (non favoris)
  Future<void> cleanupOldArticles() async {
    final localArticles = await DatabaseHelper.instance.getArticles();

    for (final article in localArticles) {
      if (article.isFavorite == 1) continue; // garder favoris

      try {
        await fetchArticleById(article.id); // test existence
      } catch (_) {
        await DatabaseHelper.instance.deleteArticle(article.id);
      }
    }
  }
}
