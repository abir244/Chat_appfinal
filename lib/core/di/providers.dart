import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/repositories/user_repository.dart';
import 'package:chat_app/data/repositories/news_repository.dart';
import 'package:chat_app/data/repositories/unsplash_repository.dart';
import 'package:chat_app/presentation/auth/viewmodels/login_viewmodel.dart';
import 'package:chat_app/presentation/auth/viewmodels/register_viewmodel.dart';
import 'package:chat_app/presentation/chat/viewmodels/chat_viewmodel.dart';
import 'package:chat_app/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:chat_app/presentation/home/viewmodels/news_viewmodel.dart';
import 'package:chat_app/presentation/home/viewmodels/unsplash_viewmodel.dart';
import 'package:chat_app/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider =
Provider<SupabaseClient>((_) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState>(
      (ref) => ref.watch(supabaseClientProvider).auth.onAuthStateChange,
);

final authRepositoryProvider = Provider<IAuthRepository>(
      (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

final userRepositoryProvider = Provider<IUserRepository>(
      (ref) => UserRepository(ref.watch(supabaseClientProvider)),
);

final chatRepositoryProvider = Provider<IChatRepository>(
      (ref) => ChatRepository(ref.watch(supabaseClientProvider)),
);

final newsRepositoryProvider = Provider<INewsRepository>(
  (ref) => NewsRepository(),
);

final unsplashRepositoryProvider = Provider<IUnsplashRepository>(
  (ref) => UnsplashRepository(),
);

final loginViewModelProvider =
StateNotifierProvider.autoDispose<LoginViewModel, LoginState>(
      (ref) => LoginViewModel(ref.watch(authRepositoryProvider)),
);

final registerViewModelProvider =
StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>(
      (ref) => RegisterViewModel(ref.watch(authRepositoryProvider)),
);

final homeViewModelProvider =
StateNotifierProvider.autoDispose<HomeViewModel, HomeState>(
      (ref) => HomeViewModel(ref.watch(chatRepositoryProvider)),
);

final searchViewModelProvider =
StateNotifierProvider.autoDispose<SearchViewModel, SearchState>(
      (ref) => SearchViewModel(ref.watch(userRepositoryProvider)),
);

final newsViewModelProvider = StateNotifierProvider.autoDispose<NewsViewModel, NewsState>(
  (ref) => NewsViewModel(ref.watch(newsRepositoryProvider)),
);

final unsplashViewModelProvider = StateNotifierProvider.autoDispose<UnsplashViewModel, UnsplashState>(
  (ref) => UnsplashViewModel(ref.watch(unsplashRepositoryProvider)),
);

final chatViewModelProvider = StateNotifierProvider.autoDispose
    .family<ChatViewModel, ChatState, UserModel>(
      (ref, receiver) => ChatViewModel(
    repository: ref.watch(chatRepositoryProvider),
    receiver: receiver,
  ),
);
