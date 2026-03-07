import 'package:chat_app/data/models/news_model.dart';
import 'package:chat_app/data/repositories/news_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsState {
  final List<NewsModel> news;
  final bool isLoading;
  final String? error;

  const NewsState({
    this.news = const [],
    this.isLoading = false,
    this.error,
  });

  NewsState copyWith({
    List<NewsModel>? news,
    bool? isLoading,
    String? error,
  }) {
    return NewsState(
      news: news ?? this.news,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NewsViewModel extends StateNotifier<NewsState> {
  final INewsRepository _repo;

  NewsViewModel(this._repo) : super(const NewsState()) {
    loadNews();
  }

  Future<void> loadNews() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final news = await _repo.getTopNews();
      state = state.copyWith(news: news, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
