import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/presentation/widgets/kuli_nav_bar.dart';
import 'package:chat_app/presentation/widgets/kuli_widgets.dart';
import 'package:chat_app/presentation/chat/views/chat_screen.dart';
import 'package:chat_app/presentation/profile/views/profile_screen.dart';
import 'package:chat_app/core/di/providers.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/presentation/home/viewmodels/home_viewmodel.dart';
import 'package:chat_app/presentation/search/viewmodels/search_viewmodel.dart';
import 'package:chat_app/presentation/home/viewmodels/news_viewmodel.dart';
import 'package:chat_app/presentation/home/viewmodels/unsplash_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        ref.read(homeViewModelProvider.notifier).loadConversations(user.id);
        ref.read(searchViewModelProvider.notifier).onQueryChanged('');
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const NewsFeedPage(),   // Page 0: Global News
      const TravelFeedPage(), // Page 1: Unsplash Travel Explore
      const Center(child: Text('Magic Content', style: TextStyle(color: Colors.white))),
      ChatsPage(searchController: _searchCtrl, onRefresh: _refresh),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          pages[_currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: KuliNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewsFeedPage extends ConsumerWidget {
  const NewsFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsState = ref.watch(newsViewModelProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 28),
                const Text('Global News', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const Icon(Icons.search, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: newsState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: KuliColors.primary))
                  : newsState.error != null
                      ? Center(child: Text('Error: ${newsState.error}', style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: newsState.news.length,
                          itemBuilder: (context, index) {
                            final article = newsState.news[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: KuliGlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (article.image.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                        child: Image.network(article.image, height: 200, width: double.infinity, fit: BoxFit.cover),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(article.sourceName, style: const TextStyle(color: KuliColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                          const SizedBox(height: 8),
                                          Text(article.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 8),
                                          Text(article.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: KuliColors.textSecondary, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class TravelFeedPage extends ConsumerWidget {
  const TravelFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unsplashState = ref.watch(unsplashViewModelProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.explore_outlined, color: Colors.white, size: 28),
                const Text('Travel Explore', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const Icon(Icons.search, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: unsplashState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: KuliColors.primary))
                  : unsplashState.error != null
                      ? Center(child: Text('Error: ${unsplashState.error}', style: const TextStyle(color: Colors.red)))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: unsplashState.photos.length,
                          itemBuilder: (context, index) {
                            final photo = unsplashState.photos[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: KuliGlassCard(
                                padding: EdgeInsets.zero,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                      child: Image.network(photo.url, height: 250, width: double.infinity, fit: BoxFit.cover),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('By ${photo.userName}', style: const TextStyle(color: KuliColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                          const SizedBox(height: 8),
                                          Text(photo.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatsPage extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final VoidCallback onRefresh;
  const ChatsPage({super.key, required this.searchController, required this.onRefresh});

  @override
  ConsumerState<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() => _query = widget.searchController.text);
      ref.read(searchViewModelProvider.notifier).onQueryChanged(_query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(homeViewModelProvider);
    final searchState = ref.watch(searchViewModelProvider);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.white),
                const Text('Messages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  onPressed: widget.onRefresh,
                ),
              ],
            ),
            const SizedBox(height: 20),
            KuliTextField(
              controller: widget.searchController,
              hintText: 'Search people to text...',
            ),
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => widget.onRefresh(),
                child: _query.isEmpty
                    ? _buildConversationList(vmState, searchState, currentUserId)
                    : _buildSearchResults(searchState, currentUserId),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList(HomeState vmState, SearchState searchState, String? currentUserId) {
    if (vmState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: KuliColors.primary));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (vmState.conversations.isNotEmpty) ...[
          const Text('Recent Chats', style: TextStyle(color: KuliColors.textSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...vmState.conversations.asMap().entries.map((entry) {
            final chat = entry.value;
            return _ChatTile(
              index: entry.key + 1,
              title: chat['display_name'] ?? 'Unknown',
              subtitle: chat['last_message'] ?? 'No messages yet',
              avatarUrl: chat['avatar_url'],
              onTap: () => _openChat(chat['chat_id'], chat['display_name'], chat['avatar_url']),
            );
          }),
          const SizedBox(height: 32),
        ],
        const Text('Suggested for you', style: TextStyle(color: KuliColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (searchState.results.isEmpty)
          const Center(child: Text('No users found.', style: TextStyle(color: Colors.grey)))
        else
          ...searchState.results.where((u) => u.id != currentUserId).map((user) {
            return _ChatTile(
              index: 0,
              title: user.username,
              subtitle: 'Start a new conversation',
              avatarUrl: user.avatarUrl,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(receiver: user))),
            );
          }),
      ],
    );
  }

  Widget _buildSearchResults(SearchState searchState, String? currentUserId) {
    if (searchState.isLoading) return const Center(child: CircularProgressIndicator());
    final results = searchState.results.where((u) => u.id != currentUserId).toList();
    if (results.isEmpty) return const Center(child: Text('No results found.', style: TextStyle(color: Colors.grey)));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return _ChatTile(
          index: index + 1,
          title: user.username,
          subtitle: user.email,
          avatarUrl: user.avatarUrl,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(receiver: user))),
        );
      },
    );
  }

  void _openChat(String id, String name, String? avatar) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiver: UserModel(id: id, username: name, email: '', avatarUrl: avatar),
        ),
      ),
    ).then((_) => widget.onRefresh());
  }
}

class _ChatTile extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final String? avatarUrl;
  final VoidCallback onTap;

  const _ChatTile({required this.index, required this.title, required this.subtitle, this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: KuliGlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (index > 0) ...[
                Text('$index', style: const TextStyle(color: KuliColors.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
              ],
              CircleAvatar(
                radius: 24,
                backgroundColor: KuliColors.background,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null ? Text(title.isNotEmpty ? title[0].toUpperCase() : '?', style: const TextStyle(color: KuliColors.primary)) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: KuliColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 12, color: KuliColors.glassBorder),
            ],
          ),
        ),
      ),
    );
  }
}
