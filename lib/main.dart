import 'package:chat_app/core/constants/app_constants.dart';
import 'package:chat_app/core/di/providers.dart';
import 'package:chat_app/presentation/auth/views/login_screen.dart';
import 'package:chat_app/presentation/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Kulikéun Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        primaryColor: const Color(0xFF9D59FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9D59FF),
          secondary: Color(0xFF7000FF),
          surface: Color(0xFF1E1E2E),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Color(0xFFB0B0C0)),
        ),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (state) => state.session != null
            ? const HomeScreen()
            : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Color(0xFF9D59FF))),
        ),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}
