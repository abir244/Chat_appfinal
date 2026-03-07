import 'package:chat_app/core/di/providers.dart';
import 'package:chat_app/presentation/auth/views/register_screen.dart';
import 'package:chat_app/presentation/widgets/kuli_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(loginViewModelProvider);
    final vm = ref.read(loginViewModelProvider.notifier);

    ref.listen(loginViewModelProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
        vm.clearError();
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9D59FF).withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.wb_sunny_outlined, size: 80, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Kulikéun',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 60),
                  const Text(
                    'Welcome back',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  KuliTextField(
                    controller: _emailCtrl,
                    hintText: 'Your email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  KuliTextField(
                    controller: _passCtrl,
                    hintText: 'Your password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  KuliButton(
                    text: 'Continue',
                    isLoading: vmState.isLoading,
                    onPressed: () {
                      vm.login(
                        email: _emailCtrl.text.trim(),
                        password: _passCtrl.text.trim(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      'Don\'t have account? Register',
                      style: TextStyle(color: Color(0xFF606070)),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSocialButton(Icons.g_mobiledata, 'Continue with Google'),
                  const SizedBox(height: 12),
                  _buildSocialButton(Icons.apple, 'Continue with Apple'),
                  const SizedBox(height: 12),
                  _buildSocialButton(Icons.discord, 'Continue with Discord'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String text) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
