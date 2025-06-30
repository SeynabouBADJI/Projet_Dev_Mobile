import 'package:flutter/material.dart';
import '../databases/database_helper.dart';
import '../models/article.dart';
import 'Article_screen.dart';

class FavoriteArticlesScreen extends StatefulWidget {
  const FavoriteArticlesScreen({super.key});

  @override
  State<FavoriteArticlesScreen> createState() => _FavoriteArticlesScreenState();
}

class _FavoriteArticlesScreenState extends State<FavoriteArticlesScreen> {
  late Future<List<Article>> favoriteArticles;

  @override
  void initState() {
    super.initState();
    favoriteArticles = _loadFavorites();
  }

  Future<List<Article>> _loadFavorites() async {
    final allArticles = await DatabaseHelper.instance.getArticles();
    return allArticles.where((article) => article.isFavorite).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<Article>>(
        future: favoriteArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun article favori.'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ListTile(
                title: Text(article.title),
                subtitle: Text('Par ${article.by}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ArticleScreen(article: article),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

