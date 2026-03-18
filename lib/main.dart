import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/background_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeBackgroundService();
  runApp(const ProxyAIApp());
}

class ProxyAIApp extends StatelessWidget {
  const ProxyAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProxyAI',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const _InitialRoute(),
    );
  }
}

class _InitialRoute extends StatefulWidget {
  const _InitialRoute();

  @override
  State<_InitialRoute> createState() => _InitialRouteState();
}

class _InitialRouteState extends State<_InitialRoute> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final done = await isOnboardingDone();
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _onboardingDone = done);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D1117),
        body: Center(
          child: Text(
            'ProxyAI',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF0F6FC),
              letterSpacing: 0.8,
            ),
          ),
        ),
      );
    }
    return _onboardingDone! ? const HomeScreen() : const OnboardingScreen();
  }
}
