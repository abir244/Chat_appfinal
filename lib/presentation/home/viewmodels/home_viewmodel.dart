import 'dart:async';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final List<Map<String, dynamic>> conversations;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.conversations = const [],
    this.isLoading = true,
    this.error,
  });

  HomeState copyWith({
    List<Map<String, dynamic>>? conversations,
    bool? isLoading,
    String? error,
  }) =>
      HomeState(
        conversations: conversations ?? this.conversations,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class HomeViewModel extends StateNotifier<HomeState> {
  final IChatRepository _repo;
  HomeViewModel(this._repo) : super(const HomeState());

  Future<void> loadConversations(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final data = await _repo.getConversations(userId);
      state = state.copyWith(conversations: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}