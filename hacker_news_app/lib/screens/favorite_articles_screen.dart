import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ArticleProvider.dart';
import 'Article_screen.dart';

class FavoriteArticlesScreen extends StatelessWidget {
  const FavoriteArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          final favorites = articleProvider.favoriteArticles;

          if (articleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            );
          }

          if (favorites.isEmpty) {
            return const Center(child: Text('Aucun article favori.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final article = favorites[index];
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
