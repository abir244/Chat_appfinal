import 'package:equatable/equatable.dart';

enum MessageType { text, image, video }

class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String? receiverId; // Nullable for groups
  final String? groupId;    // Nullable for direct chats
  final String text;
  final String? fileUrl;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    this.receiverId,
    this.groupId,
    required this.text,
    this.fileUrl,
    this.type = MessageType.text,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) => MessageModel(
    id: map['id'],
    senderId: map['sender_id'],
    receiverId: map['receiver_id'],
    groupId: map['group_id'],
    text: map['text'] ?? '',
    fileUrl: map['file_url'],
    isRead: map['is_read'] ?? false,
    type: MessageType.values.firstWhere(
      (e) => e.name == (map['type'] ?? 'text'),
      orElse: () => MessageType.text,
    ),
    createdAt: DateTime.parse(map['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'sender_id': senderId,
    'receiver_id': receiverId,
    'group_id': groupId,
    'text': text,
    'file_url': fileUrl,
    'type': type.name,
    'is_read': isRead,
  };

  @override
  List<Object?> get props => [id, isRead];
}
