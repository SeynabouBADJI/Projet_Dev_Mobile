// import 'package:flutter/material.dart';
// import 'package:hacker_news_app/screens/Article_screen.dart';
// import '../models/article.dart';
// import '../services/api_service.dart';
// import '../databases/Database_helper.dart';
// import 'saved_articles_screen.dart';
// import 'favorite_articles_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ApiService apiService = ApiService();
//   late Future<List<Article>> futureArticles;

//   @override
//   void initState() {
//     super.initState();
//     cleanupOldArticles();
//     futureArticles = loadArticlesWithCache();
//   }

//   Future<List<Article>> loadArticlesWithCache() async {
//     final ids = await apiService.fetchTopStoryIds();
//     List<Article> articles = [];

//     for (var id in ids) {
//       Article? localArticle = await DatabaseHelper.instance.getArticleById(id);
//       if (localArticle != null) {
//         articles.add(localArticle);
//       } else {
//         try {
//           Article fetchedArticle = await apiService.fetchArticleById(id);
//           await DatabaseHelper.instance.insertArticle(fetchedArticle);
//           articles.add(fetchedArticle);
//         } catch (e) {
//           print("Erreur chargement article $id depuis API : $e");
//         }
//       }
//     }
//     return articles;
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
//   }

//   Future<bool> isArticleSaved(int id) async {
//     Article? article = await DatabaseHelper.instance.getArticleById(id);
//     return article != null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Hacker News'),
//         backgroundColor: Colors.deepOrange,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.bookmarks),
//             tooltip: 'Articles sauvegardés',
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const SavedArticlesScreen()),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.favorite),
//             tooltip: 'Favoris',
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const FavoriteArticlesScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Article>>(
//         future: futureArticles,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//                 child: CircularProgressIndicator(color: Colors.deepOrange));
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Erreur : ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('Aucun article trouvé.'));
//           }

//           final articles = snapshot.data!;
//           return ListView.builder(
//             padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             itemCount: articles.length,
//             itemBuilder: (context, index) {
//               final article = articles[index];
//               return Card(
//                 elevation: 3,
//                 margin: const EdgeInsets.symmetric(vertical: 6),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(12),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => ArticleScreen(article: article),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 14, horizontal: 16),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 article.title,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                               const SizedBox(height: 6),
//                               Text(
//                                 'Par ${article.by} • ${article.descendants ?? 0} commentaires',
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         FutureBuilder<bool>(
//                           future: isArticleSaved(article.id),
//                           builder: (context, snapshotSaved) {
//                             bool isSaved =
//                                 snapshotSaved.data == true ? true : false;

//                             return Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                   icon: Icon(
//                                     isSaved
//                                         ? Icons.bookmark
//                                         : Icons.bookmark_add,
//                                     color: Colors.deepOrange,
//                                   ),
//                                   tooltip: 'Sauvegarder',
//                                   onPressed: () async {
//                                     if (!isSaved) {
//                                       await DatabaseHelper.instance
//                                           .insertArticle(article);
//                                       setState(() {});
//                                       ScaffoldMessenger.of(context)
//                                           .showSnackBar(
//                                         const SnackBar(
//                                           content: Text("Article sauvegardé !"),
//                                           backgroundColor: Colors.deepOrange,
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 ),
//                                 IconButton(
//                                   icon: Icon(
//                                     article.isFavorite
//                                         ? Icons.favorite
//                                         : Icons.favorite_border,
//                                     color: article.isFavorite
//                                         ? Colors.red
//                                         : Colors.grey,
//                                   ),
//                                   tooltip: 'Ajouter aux favoris',
//                                   onPressed: () async {
//                                     setState(() {
//                                       article.isFavorite = !article.isFavorite;
//                                     });
//                                     await DatabaseHelper.instance
//                                         .insertArticle(article);
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
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
      body: articleProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : articleProvider.articles.isEmpty
              ? const Center(child: Text('Aucun article trouvé.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: articleProvider.articles.length,
                  itemBuilder: (context, index) {
                    final article = articleProvider.articles[index];
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
                                  IconButton(
                                    icon: Icon(
                                      Icons.bookmark,
                                      color: Colors.deepOrange,
                                    ),
                                    tooltip: 'Sauvegarder',
                                    onPressed: () {
                                      articleProvider.saveArticle(article);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Article sauvegardé !"),
                                          backgroundColor: Colors.deepOrange,
                                        ),
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
