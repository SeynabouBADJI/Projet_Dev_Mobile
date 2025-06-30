import 'package:flutter/material.dart';
import 'package:hacker_news_app/screens/Article_screen.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../databases/database_helper.dart';
import 'saved_articles_screen.dart';
import 'favorite_articles_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Article>> futureArticles;

  @override
  void initState() {
    super.initState();
    futureArticles = loadArticles();
  }

  Future<List<Article>> loadArticles() async {
    final ids = await apiService.fetchTopStoryIds();
    final articles = await Future.wait(
      ids.map((id) => apiService.fetchArticleById(id)),
    );
    return articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacker News'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmarks),
            tooltip: 'Articles sauvegardés',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedArticlesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoris',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoriteArticlesScreen()),
              );
            },
          ),
        ],

      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepOrange));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun article trouvé.'));
          }

          final articles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          IconButton(
                            icon: const Icon(Icons.bookmark_add, color: Colors.deepOrange),
                            tooltip: 'Sauvegarder',
                            onPressed: () async {
                              try {
                                await DatabaseHelper.instance.insertArticle(article);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Article sauvegardé !"),
                                    backgroundColor: Colors.deepOrange,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erreur lors de la sauvegarde : $e")),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              article.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: article.isFavorite ? Colors.red : Colors.grey,
                            ),
                            tooltip: 'Ajouter aux favoris',
                            onPressed: () async {
                              setState(() {
                                article.isFavorite = !article.isFavorite;
                              });
                              await DatabaseHelper.instance.insertArticle(article); // Met à jour
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
          );
        },
      ),
    );
  }
}
