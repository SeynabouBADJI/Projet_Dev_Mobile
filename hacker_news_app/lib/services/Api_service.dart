import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';
import '../models/comment.dart';


class ApiService {
  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';

  // Récupérer les IDs des articles populaires
  Future<List<int>> fetchTopStoryIds() async {
    final url = Uri.parse('$baseUrl/topstories.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> ids = json.decode(response.body);
      return ids.cast<int>().take(20).toList(); // On limite à 20 articles
    } else {
      throw Exception('Erreur lors du chargement des articles');
    }
  }

  // Récupérer un article avec son ID
  Future<Article> fetchArticleById(int id) async {
    final url = Uri.parse('$baseUrl/item/$id.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Article.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement de l’article');
    }
  }

  Future<bool> isArticleAvailable(int id) async {
  final response = await http.get(Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'));
  return response.statusCode == 200 && response.body != 'null';
}

Future<Comment> fetchCommentById(int id) async {
  final response = await http.get(Uri.parse('https://hacker-news.firebaseio.com/v0/item/$id.json'));
  if (response.statusCode == 200) {
    return Comment.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Erreur lors du chargement du commentaire');
  }
}



}

