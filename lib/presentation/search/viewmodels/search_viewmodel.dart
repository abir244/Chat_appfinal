import 'dart:async';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/repositories/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchState {
  final List<UserModel> results;
  final bool isLoading;
  final String query;
  final String? error;

  const SearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.error,
  });

  SearchState copyWith({
    List<UserModel>? results,
    bool? isLoading,
    String? query,
    String? error,
  }) =>
      SearchState(
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        query: query ?? this.query,
        error: error,
      );
}

class SearchViewModel extends StateNotifier<SearchState> {
  final IUserRepository _repo;
  Timer? _debounce;

  SearchViewModel(this._repo) : super(const SearchState());

  void onQueryChanged(String query) {
    state = state.copyWith(query: query, isLoading: query.isNotEmpty);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
          () => _search(query),
    );
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }
    try {
      final users = await _repo.searchUsers(query);
      state = state.copyWith(results: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}