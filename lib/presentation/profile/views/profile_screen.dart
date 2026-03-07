import 'dart:io';
import 'package:chat_app/core/di/providers.dart';
import 'package:chat_app/core/theme/app_theme.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/presentation/widgets/kuli_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _usernameCtrl = TextEditingController();
  bool _isLoading = false;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final user = await ref.read(userRepositoryProvider).getUserProfile(userId);
    setState(() {
      _userModel = user;
      _usernameCtrl.text = user.username;
    });
  }

  Future<void> _updateProfile({File? image}) async {
    setState(() => _isLoading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await ref.read(userRepositoryProvider).updateProfile(
            userId: userId,
            username: _usernameCtrl.text.trim(),
            avatar: image,
          );
      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).logout();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _updateProfile(image: File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: _userModel == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: KuliColors.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: KuliColors.surface,
                          backgroundImage: _userModel!.avatarUrl != null
                              ? NetworkImage(_userModel!.avatarUrl!)
                              : null,
                          child: _userModel!.avatarUrl == null
                              ? Text(
                                  _userModel!.username.isNotEmpty ? _userModel!.username[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: KuliColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  KuliTextField(
                    controller: _usernameCtrl,
                    hintText: 'Username',
                  ),
                  const SizedBox(height: 24),
                  KuliButton(
                    text: 'Save Changes',
                    onPressed: () => _updateProfile(),
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  KuliButton(
                    text: 'Logout',
                    onPressed: _logout,
                    isSecondary: true,
                  ),
                ],
              ),
            ),
    );
  }
}
