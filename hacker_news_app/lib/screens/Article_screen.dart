import 'package:flutter/material.dart';
import 'package:hacker_news_app/providers/CommentProvider.dart';
import 'package:hacker_news_app/widgets/CommentWidget.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/Article.dart';
import '../providers/ArticleProvider.dart';
import '../widgets/CommentWidget.dart';

class ArticleScreen extends StatefulWidget {
  final Article article;
  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late final WebViewController _controller;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(
        Uri.parse(widget.article.url ?? 'https://news.ycombinator.com/item?id=${widget.article.id}'),
      );
  }

  @override
  Widget build(BuildContext context) {
    final commentProvider = Provider.of<CommentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: WebViewWidget(controller: _controller),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(_showComments ? Icons.comment : Icons.comment_bank_outlined),
              label: Text(_showComments ? 'Masquer les commentaires' : 'Afficher les commentaires'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () async {
                setState(() {
                  _showComments = !_showComments;
                });
                if (_showComments) {
                  await commentProvider.loadComments(widget.article.kids);
                } else {
                  commentProvider.clearComments();
                }
              },
            ),
          ),
          if (_showComments)
            Expanded(
              flex: 5,
              child: commentProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: commentProvider.comments.length,
                      itemBuilder: (context, index) {
                        final comment = commentProvider.comments[index];
                        return CommentWidget(comment: comment);
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
