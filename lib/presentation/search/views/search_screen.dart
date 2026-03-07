import 'package:chat_app/core/di/providers.dart';
import 'package:chat_app/presentation/chat/views/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(searchViewModelProvider);
    final vm = ref.read(searchViewModelProvider.notifier);
    final chatRepo = ref.read(chatRepositoryProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by username...',
            border: InputBorder.none,
          ),
          onChanged: vm.onQueryChanged,
        ),
      ),
      body: vmState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vmState.query.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Search for users', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : vmState.results.isEmpty
                  ? const Center(child: Text('No users found'))
                  : ListView.builder(
                      itemCount: vmState.results.length,
                      itemBuilder: (_, i) {
                        final user = vmState.results[i];
                        if (user.id == currentUserId) return const SizedBox.shrink();

                        return FutureBuilder<String?>(
                          future: chatRepo.getRequestStatus(currentUserId, user.id),
                          builder: (context, snapshot) {
                            final status = snapshot.data;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.deepPurple,
                                child: Text(
                                  user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(user.username),
                              subtitle: Text(user.email),
                              trailing: _buildTrailing(status, chatRepo, user.id),
                              onTap: status == 'accepted'
                                  ? () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => ChatScreen(receiver: user)),
                                      )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildTrailing(String? status, dynamic chatRepo, String receiverId) {
    if (status == 'accepted') {
      return const Icon(Icons.chat, color: Colors.deepPurple);
    } else if (status == 'pending') {
      return const Chip(label: Text('Pending'), backgroundColor: Colors.orangeAccent);
    } else if (status == 'rejected') {
      return const Chip(label: Text('Rejected'), backgroundColor: Colors.redAccent);
    } else {
      return ElevatedButton(
        onPressed: () async {
          await chatRepo.sendChatRequest(receiverId);
          setState(() {}); // Refresh to show pending status
        },
        child: const Text('Request'),
      );
    }
  }
}
