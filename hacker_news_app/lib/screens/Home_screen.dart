import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/Article_screen.dart';
import '../screens/saved_articles_screen.dart';
import '../screens/favorite_articles_screen.dart';
import '../providers/ArticleProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSavedPressed = false;
  bool _isFavoritePressed = false;

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);

    if (articleProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (articleProvider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            articleProvider.error!,
            style: const TextStyle(color: Colors.red, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (articleProvider.allArticles.isEmpty) {
      return const Center(child: Text('Aucun article disponible.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacker News'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmarks,
              color: _isSavedPressed ? Colors.orange : Colors.white,
            ),
            tooltip: 'Articles sauvegardés',
            onPressed: () {
              setState(() {
                _isSavedPressed = !_isSavedPressed;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedArticlesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: _isFavoritePressed ? Colors.orange : Colors.white,
            ),
            tooltip: 'Favoris',
            onPressed: () {
              setState(() {
                _isFavoritePressed = !_isFavoritePressed;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteArticlesScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: articleProvider.allArticles.length,
        itemBuilder: (context, index) {
          final article = articleProvider.allArticles[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticleScreen(article: article),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Par ${article.by} • ${article.descendants ?? 0} commentaires',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder<bool>(
                          future: articleProvider.isArticleSaved(article.id),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Icon(
                                Icons.bookmark_outline,
                                color: Colors.grey,
                              );
                            }
                            bool isSaved = snapshot.data!;
                            return IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_outline,
                                color: isSaved ? Colors.orange : Colors.grey,
                              ),
                              tooltip: isSaved ? 'Retirer des sauvegardés' : 'Sauvegarder',
                              onPressed: () async {
                                if (isSaved) {
                                  await articleProvider.removeArticle(article.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Article retiré des sauvegardés."),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                } else {
                                  await articleProvider.saveArticle(article);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Article sauvegardé !"),
                                      backgroundColor: Colors.deepOrange,
                                    ),
                                  );
                                }
                                setState(() {}); // Pour rafraîchir l'icône
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            article.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: article.isFavorite ? Colors.red : Colors.grey,
                          ),
                          tooltip: 'Ajouter aux favoris',
                          onPressed: () {
                            articleProvider.toggleFavorite(article);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
