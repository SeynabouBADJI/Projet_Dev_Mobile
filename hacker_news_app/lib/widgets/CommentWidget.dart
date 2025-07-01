
import 'package:flutter/material.dart';
import '../models/Comment.dart';
import '../services/Api_service.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final int depth;

  const CommentWidget({super.key, required this.comment, this.depth = 0});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _showReplies = false;
  bool _isLoadingReplies = false;
  List<Comment> _replies = [];

  Future<void> _loadReplies() async {
    if (_isLoadingReplies || _replies.isNotEmpty) return;
    if (widget.comment.kids == null || widget.comment.kids!.isEmpty) return;

    setState(() {
      _isLoadingReplies = true;
    });

    try {
      // Charger les enfants en parallèle
      final loadedReplies = await Future.wait(
        widget.comment.kids!.map((id) => ApiService().fetchCommentById(id)),
      );
      setState(() {
        _replies = loadedReplies.whereType<Comment>().toList();
        _showReplies = true;
      });
    } catch (e) {
      // Gérer erreur si nécessaire
    } finally {
      setState(() {
        _isLoadingReplies = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.depth * 16.0, right: 8.0, top: 6),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Par ${widget.comment.by ?? "Anonyme"}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(widget.comment.text ?? '[Commentaire vide]'),
              if (widget.comment.kids != null && widget.comment.kids!.isNotEmpty)
                TextButton(
                  onPressed: () {
                    if (_showReplies) {
                      setState(() {
                        _showReplies = false;
                      });
                    } else {
                      _loadReplies();
                    }
                  },
                  child: Text(_showReplies
                      ? 'Masquer les réponses'
                      : 'Afficher les réponses (${widget.comment.kids!.length})'),
                ),
              if (_isLoadingReplies) const CircularProgressIndicator(),
              if (_showReplies)
                ..._replies
                    .map((reply) => CommentWidget(comment: reply, depth: widget.depth + 1))
                    .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
