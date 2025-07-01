
import 'package:flutter/material.dart';
import '../models/Comment.dart';
import '../services/Api_service.dart';

class CommentProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();

  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> loadComments(List<int>? commentIds) async {
    if (commentIds == null || commentIds.isEmpty) return;
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final fetchedComments = await Future.wait(
        commentIds.map((id) => apiService.fetchCommentById(id)),
      );
      _comments = fetchedComments.whereType<Comment>().toList();
    } catch (e) {
      // gérer l’erreur ici si besoin
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearComments() {
    _comments = [];
    notifyListeners();
  }
}
