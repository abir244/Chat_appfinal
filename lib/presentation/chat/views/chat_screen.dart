import 'dart:io';
import 'package:chat_app/core/di/providers.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/data/models/message_model.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final UserModel receiver;
  const ChatScreen({super.key, required this.receiver});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMedia(MessageType type) async {
    final picker = ImagePicker();
    XFile? pickedFile;
    
    if (type == MessageType.image) {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    } else if (type == MessageType.video) {
      pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      await ref.read(chatRepositoryProvider).sendMessage(
            senderId: currentUserId,
            receiverId: widget.receiver.id,
            text: type == MessageType.image ? '📷 Photo' : '🎥 Video',
            type: type,
            file: File(pickedFile.path),
          );
    }
  }

  void _sendText() {
    if (_msgCtrl.text.trim().isEmpty) return;
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;
    ref.read(chatRepositoryProvider).sendMessage(
          senderId: currentUserId,
          receiverId: widget.receiver.id,
          text: _msgCtrl.text.trim(),
        );
    _msgCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.receiver.username,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Online', style: TextStyle(color: KuliColors.primary, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: ref.read(chatRepositoryProvider).getMessages(
                    receiverId: widget.receiver.id,
                  ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: KuliColors.primary));
                }

                final messages = snapshot.data ?? [];
                
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: KuliColors.textSecondary, size: 48),
                        const SizedBox(height: 16),
                        Text('No messages with ${widget.receiver.username} yet.', 
                          style: const TextStyle(color: KuliColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollCtrl,
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;

                    if (!isMe && !msg.isRead) {
                      ref.read(chatRepositoryProvider).markMessageAsRead(msg.id);
                    }

                    return _buildKuliBubble(msg, isMe);
                  },
                );
              },
            ),
          ),
          _buildKuliInputArea(),
        ],
      ),
    );
  }

  Widget _buildKuliBubble(MessageModel msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: KuliColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    widget.receiver.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFF2E2E3E) : const Color(0xFF1E1E2E),
              borderRadius: BorderRadius.circular(20),
              border: isMe ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.type == MessageType.image && msg.fileUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(msg.fileUrl!),
                  ),
                if (msg.text.isNotEmpty)
                  Text(
                    msg.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                  ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(msg.createdAt),
                  style: const TextStyle(color: Colors.white24, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKuliInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
      decoration: const BoxDecoration(color: KuliColors.background),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF606070)), onPressed: () => _sendMedia(MessageType.image)),
          IconButton(icon: const Icon(Icons.image_outlined, color: Color(0xFF606070)), onPressed: () => _sendMedia(MessageType.image)),
          IconButton(icon: const Icon(Icons.folder_open_outlined, color: Color(0xFF606070)), onPressed: () {}),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _msgCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: TextStyle(color: Color(0xFF606070)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                ),
                onSubmitted: (_) => _sendText(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendText,
            child: Container(
              height: 50, width: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [KuliColors.primary, KuliColors.secondary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
