import 'dart:io';
import 'package:chat_app/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

abstract class IChatRepository {
  Future<void> sendMessage({
    required String senderId,
    String? receiverId,
    String? groupId,
    required String text,
    MessageType type = MessageType.text,
    File? file,
  });
  Stream<List<MessageModel>> getMessages({
    String? receiverId,
    String? groupId,
  });
  Future<List<Map<String, dynamic>>> getConversations(String userId);
  Future<void> sendChatRequest(String receiverId);
  Future<void> acceptChatRequest(String requestId);
  Future<void> rejectChatRequest(String requestId);
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId);
  Future<String?> getRequestStatus(String userId1, String userId2);
  Stream<int> watchPendingRequestsCount(String userId);
  Future<void> unfriend(String otherUserId);
  
  // Group management
  Future<String> createGroup({required String name, String? description, String? avatarUrl});
  Future<void> addGroupMember(String groupId, String userId, {String role = 'member'});
  Future<List<Map<String, dynamic>>> getMyGroups(String userId);
  
  // Message status
  Future<void> markMessageAsRead(String messageId);
  
  // New Modern Features
  Future<void> deleteMessage(String messageId);
  Future<List<MessageModel>> searchMessages(String query, {String? receiverId, String? groupId});
}

class ChatRepository implements IChatRepository {
  final SupabaseClient _client;
  const ChatRepository(this._client);

  @override
  Future<void> sendMessage({
    required String senderId,
    String? receiverId,
    String? groupId,
    required String text,
    MessageType type = MessageType.text,
    File? file,
  }) async {
    String? fileUrl;
    if (file != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
      await _client.storage.from('chat_files').upload(
            fileName, 
            file, 
            fileOptions: const FileOptions(upsert: true),
          );
      fileUrl = _client.storage.from('chat_files').getPublicUrl(fileName);
    }

    await _client.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'group_id': groupId,
      'text': text,
      'type': type.name,
      'file_url': fileUrl,
    });
  }

  @override
  Stream<List<MessageModel>> getMessages({
    String? receiverId,
    String? groupId,
  }) {
    final currentUserId = _client.auth.currentUser!.id;
    var query = _client.from('messages').stream(primaryKey: ['id']).order('created_at', ascending: false);
    
    return query.map((rows) {
      if (groupId != null) {
        return rows
            .where((r) => r['group_id'] == groupId)
            .map((r) => MessageModel.fromMap(r))
            .toList();
      } else {
        return rows
            .where((r) =>
                (r['sender_id'] == currentUserId && r['receiver_id'] == receiverId) ||
                (r['sender_id'] == receiverId && r['receiver_id'] == currentUserId))
            .map((r) => MessageModel.fromMap(r))
            .toList();
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final data = await _client.rpc('get_conversations', params: {'p_user_id': userId});
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> sendChatRequest(String receiverId) async {
    await _client.from('chat_requests').insert({
      'sender_id': _client.auth.currentUser!.id,
      'receiver_id': receiverId,
      'status': 'pending',
    });
  }

  @override
  Future<void> acceptChatRequest(String requestId) async {
    await _client.from('chat_requests').update({
      'status': 'accepted',
    }).eq('id', requestId);
  }

  @override
  Future<void> rejectChatRequest(String requestId) async {
    await _client.from('chat_requests').update({
      'status': 'rejected',
    }).eq('id', requestId);
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    final data = await _client
        .from('chat_requests')
        .select('*, sender:sender_id(username, email, avatar_url)')
        .eq('receiver_id', userId)
        .eq('status', 'pending');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<String?> getRequestStatus(String userId1, String userId2) async {
    final data = await _client
        .from('chat_requests')
        .select('status')
        .or('and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)')
        .maybeSingle();
    return data?['status'];
  }

  @override
  Stream<int> watchPendingRequestsCount(String userId) {
    return _client
        .from('chat_requests')
        .stream(primaryKey: ['id'])
        .map((event) => event
            .where((row) => row['receiver_id'] == userId && row['status'] == 'pending')
            .length);
  }

  @override
  Future<void> unfriend(String otherUserId) async {
    final currentUserId = _client.auth.currentUser!.id;
    await _client.from('chat_requests').delete().or('and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)');
    await _client.from('messages').delete().or('and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)');
  }

  @override
  Future<String> createGroup({required String name, String? description, String? avatarUrl}) async {
    final currentUserId = _client.auth.currentUser!.id;
    final res = await _client.from('groups').insert({
      'name': name,
      'description': description,
      'avatar_url': avatarUrl,
      'created_by': currentUserId,
    }).select().single();
    
    final groupId = res['id'];
    await addGroupMember(groupId, currentUserId, role: 'admin');
    return groupId;
  }

  @override
  Future<void> addGroupMember(String groupId, String userId, {String role = 'member'}) async {
    await _client.from('group_members').insert({
      'group_id': groupId,
      'user_id': userId,
      'role': role,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getMyGroups(String userId) async {
    final data = await _client.from('group_members').select('*, groups(*)').eq('user_id', userId);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> markMessageAsRead(String messageId) async {
    await _client.from('messages').update({'is_read': true}).eq('id', messageId);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _client.from('messages').delete().eq('id', messageId);
  }

  @override
  Future<List<MessageModel>> searchMessages(String query, {String? receiverId, String? groupId}) async {
    var req = _client.from('messages').select().ilike('text', '%$query%');
    if (groupId != null) req = req.eq('group_id', groupId);
    final data = await req.order('created_at', ascending: false);
    return (data as List).map((e) => MessageModel.fromMap(e)).toList();
  }
}
