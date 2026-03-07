import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const RegisterState({this.isLoading = false, this.error, this.isSuccess = false});

  RegisterState copyWith({bool? isLoading, String? error, bool? isSuccess}) =>
      RegisterState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSuccess: isSuccess ?? this.isSuccess,
      );
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  final IAuthRepository _repo;
  RegisterViewModel(this._repo) : super(const RegisterState());

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      state = state.copyWith(error: 'Please fill in all fields');
      return;
    }
    if (password != confirmPassword) {
      state = state.copyWith(error: 'Passwords do not match');
      return;
    }
    if (password.length < 6) {
      state = state.copyWith(error: 'Password must be at least 6 characters');
      return;
    }
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _repo.register(email: email, password: password, username: username);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } on PostgrestException catch (e) {
      state = state.copyWith(isLoading: false, error: 'Database error: ${e.message}');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  void clearError() => state = state.copyWith(error: null);
}
