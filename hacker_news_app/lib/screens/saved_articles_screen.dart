import 'package:flutter/material.dart';
import '../databases/Database_helper.dart';
import '../models/Article.dart';
import 'Article_screen.dart';

class SavedArticlesScreen extends StatelessWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: DatabaseHelper.instance.getArticles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Articles sauvegardés')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Articles sauvegardés')),
            body: const Center(child: Text('Aucun article sauvegardé.')),
          );
        }

        final savedArticles = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: const Text('Articles sauvegardés')),
          body: ListView.builder(
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
      },
    );
  }
}
