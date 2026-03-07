import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    username: map['username'] ?? 'Unknown',
    email: map['email'] ?? '',
    avatarUrl: map['avatar_url'],
    isOnline: map['is_online'] ?? false,
    lastSeen: map['last_seen'] != null ? DateTime.parse(map['last_seen']) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'avatar_url': avatarUrl,
    'is_online': isOnline,
    'last_seen': lastSeen?.toIso8601String(),
  };

  @override
  List<Object?> get props => [id, username, email, avatarUrl, isOnline, lastSeen];
}
