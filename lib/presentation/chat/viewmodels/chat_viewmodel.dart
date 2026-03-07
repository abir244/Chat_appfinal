import 'dart:async';
import 'package:chat_app/data/models/message_model.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = true,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: error,
      );
}

class ChatViewModel extends StateNotifier<ChatState> {
  final IChatRepository _repo;
  final UserModel receiver;
  StreamSubscription? _sub;

  ChatViewModel({required IChatRepository repository, required this.receiver})
      : _repo = repository,
        super(const ChatState()) {
    // Start loading messages immediately on initialization
    loadMessages();
  }

  void loadMessages() {
    _sub?.cancel();
    _sub = _repo
        .getMessages(receiverId: receiver.id)
        .listen(
          (msgs) => state = state.copyWith(messages: msgs, isLoading: false),
      onError: (e) =>
      state = state.copyWith(error: e.toString(), isLoading: false),
    );
  }

  Future<void> sendMessage({
    required String senderId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isSending: true);
    try {
      await _repo.sendMessage(
        senderId: senderId,
        receiverId: receiver.id,
        text: text.trim(),
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
