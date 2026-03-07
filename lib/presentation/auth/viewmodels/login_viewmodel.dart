import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;

class LoginState {
  final bool isLoading;
  final String? error;

  const LoginState({this.isLoading = false, this.error});

  LoginState copyWith({bool? isLoading, String? error}) =>
      LoginState(isLoading: isLoading ?? this.isLoading, error: error);
}

class LoginViewModel extends StateNotifier<LoginState> {
  final IAuthRepository _repo;
  LoginViewModel(this._repo) : super(const LoginState());

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      dev.log('Attempting login for: $email');
      await _repo.login(email: email, password: password);
      dev.log('Login successful');
      state = state.copyWith(isLoading: false);
    } on AuthException catch (e) {
      dev.log('Auth error during login: ${e.message}');
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      dev.log('Unexpected error during login: $e');
      state = state.copyWith(isLoading: false, error: 'Login failed: ${e.toString()}');
    }
  }

  void clearError() => state = state.copyWith(error: null);
}
