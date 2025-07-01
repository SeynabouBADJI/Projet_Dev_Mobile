import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Article.dart';
import '../screens/Article_screen.dart';
import '../providers/ArticleProvider.dart';

class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);

    final savedArticles = articleProvider.articles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles sauvegardés'),
        backgroundColor: Colors.deepOrange,
      ),
      body: savedArticles.isEmpty
          ? const Center(child: Text('Aucun article sauvegardé.'))
          : ListView.builder(
              itemCount: savedArticles.length,
              itemBuilder: (context, index) {
                final article = savedArticles[index];
                return ListTile(
                  title: Text(article.title),
                  subtitle: Text('Par ${article.by}'),
                  trailing: const Icon(Icons.arrow_forward),
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
            ),
    );
  }
}
