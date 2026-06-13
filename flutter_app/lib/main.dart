import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/session.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MovieMatchApp());

class MovieMatchApp extends StatelessWidget {
  const MovieMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MovieMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RootGate(),
    );
  }
}

/// Decides between onboarding and the main app based on a saved session.
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  int? _userId;
  String _name = 'Guest';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final id = await Session.userId();
    final name = await Session.displayName();
    if (!mounted) return;
    setState(() {
      _userId = id;
      _name = name ?? 'Guest';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userId == null) {
      return OnboardingScreen(onComplete: _restore);
    }
    return HomeShell(userId: _userId!, name: _name, onLogout: _restore);
  }
}
