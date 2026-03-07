import 'package:chat_app/data/models/unsplash_model.dart';
import 'package:chat_app/data/repositories/unsplash_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnsplashState {
  final List<UnsplashModel> photos;
  final bool isLoading;
  final String? error;

  const UnsplashState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
  });

  UnsplashState copyWith({
    List<UnsplashModel>? photos,
    bool? isLoading,
    String? error,
  }) {
    return UnsplashState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UnsplashViewModel extends StateNotifier<UnsplashState> {
  final IUnsplashRepository _repo;

  UnsplashViewModel(this._repo) : super(const UnsplashState()) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final photos = await _repo.getTravelPhotos();
      state = state.copyWith(photos: photos, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}
