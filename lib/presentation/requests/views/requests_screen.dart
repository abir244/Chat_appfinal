import 'package:chat_app/core/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    try {
      final data = await ref.read(chatRepositoryProvider).getPendingRequests(userId);
      setState(() {
        _requests = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Requests')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    final sender = req['sender'] as Map<String, dynamic>?;
                    final username = sender?['username'] ?? 'Unknown';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(username[0].toUpperCase()),
                      ),
                      title: Text(username),
                      subtitle: const Text('wants to chat with you'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await ref.read(chatRepositoryProvider).acceptChatRequest(req['id']);
                              _loadRequests();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () async {
                              await ref.read(chatRepositoryProvider).rejectChatRequest(req['id']);
                              _loadRequests();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
