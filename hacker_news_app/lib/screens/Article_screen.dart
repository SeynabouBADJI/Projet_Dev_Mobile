import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/article.dart';
import '../models/comment.dart';
import '../services/Api_service.dart';
import '../widgets/CommentWidget.dart';  // <-- importe le widget CommentWidget

class ArticleScreen extends StatefulWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late final WebViewController _controller;
  List<Comment> topLevelComments = [];
  bool _showComments = false;
  bool _isLoadingComments = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..loadRequest(Uri.parse(widget.article.url ?? 'https://news.ycombinator.com/item?id=${widget.article.id}'));
  }

  Future<void> _loadTopLevelComments() async {
    if (_isLoadingComments || topLevelComments.isNotEmpty) return;
    if (widget.article.kids == null || widget.article.kids!.isEmpty) return;

    setState(() {
      _isLoadingComments = true;
    });

    try {
      final comments = await Future.wait(
        widget.article.kids!.map((id) => ApiService().fetchCommentById(id)),
      );
      setState(() {
        topLevelComments = comments.whereType<Comment>().toList();
      });
    } catch (e) {
      // gérer erreur éventuelle
    } finally {
      setState(() {
        _isLoadingComments = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  await _loadTopLevelComments();
                }
              },
            ),
          ),
          if (_showComments)
            Expanded(
              flex: 5,
              child: _isLoadingComments
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: topLevelComments.length,
                      itemBuilder: (context, index) {
                        final comment = topLevelComments[index];
                        return CommentWidget(comment: comment);
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
