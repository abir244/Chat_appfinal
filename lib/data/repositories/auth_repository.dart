import 'package:chat_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class IAuthRepository {
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  });
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
}

class AuthRepository implements IAuthRepository {
  final SupabaseClient _client;
  const AuthRepository(this._client);

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    
    if (response.user == null) {
        throw const AuthException('Registration failed: User is null');
    }

    final user = UserModel(
      id: response.user!.id,
      username: username,
      email: email,
    );
    
    // We attempt to insert into the public users table. 
    // If it fails, we should at least have the auth user.
    try {
        await _client.from('users').upsert(user.toMap());
    } catch (e) {
        print("Error inserting into public.users: $e");
        // Depending on your logic, you might want to rethrow or ignore if the auth succeeded
    }
    
    return user;
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _client.auth
        .signInWithPassword(email: email, password: password);
    final data = await _client
        .from('users')
        .select()
        .eq('id', _client.auth.currentUser!.id)
        .single();
    return UserModel.fromMap(data);
  }

  @override
  Future<void> logout() => _client.auth.signOut();
}
