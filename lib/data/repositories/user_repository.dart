import 'dart:io';
import 'package:chat_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

abstract class IUserRepository {
  Future<List<UserModel>> searchUsers(String query);
  Future<UserModel> getUserProfile(String userId);
  Future<void> updateProfile({required String userId, String? username, File? avatar});
  Stream<List<UserModel>> getActiveUsers();
  Future<void> updatePresence(String userId, bool isOnline);
}

class UserRepository implements IUserRepository {
  final SupabaseClient _client;
  const UserRepository(this._client);

  @override
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final data = await _client
        .from('users')
        .select()
        .ilike('username', '%$query%')
        .neq('id', _client.auth.currentUser!.id)
        .limit(20);
    return (data as List).map((e) => UserModel.fromMap(e)).toList();
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    final data = await _client.from('users').select().eq('id', userId).single();
    return UserModel.fromMap(data);
  }

  @override
  Future<void> updateProfile({required String userId, String? username, File? avatar}) async {
    String? avatarUrl;
    if (avatar != null) {
      final fileName = '$userId${p.extension(avatar.path)}';
      final path = 'avatars/$fileName';
      
      // Upload with upsert so it replaces the old one
      await _client.storage.from('avatars').upload(
            path,
            avatar,
            fileOptions: const FileOptions(upsert: true),
          );
      avatarUrl = _client.storage.from('avatars').getPublicUrl(path);
    }

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isNotEmpty) {
      await _client.from('users').update(updates).eq('id', userId);
    }
  }

  @override
  Stream<List<UserModel>> getActiveUsers() {
    return _client
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('is_online', true)
        .map((data) => data.map((e) => UserModel.fromMap(e)).toList());
  }

  @override
  Future<void> updatePresence(String userId, bool isOnline) async {
    await _client.from('users').update({
      'is_online': isOnline,
      'last_seen': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }
}
