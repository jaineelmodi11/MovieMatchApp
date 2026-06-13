import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _name = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _start() async {
    final name = _name.text.trim().isEmpty ? 'Guest' : _name.text.trim();
    setState(() {
      _busy = true;
      _error = null;
    });
    final uid = await Session.deviceUid();
    final userId = await ApiService.instance.importOrGetUser(uid: uid, name: name);
    if (!mounted) return;
    if (userId == null) {
      setState(() {
        _busy = false;
        _error = 'Could not reach the backend. Is it running?';
      });
      return;
    }
    await Session.save(userId: userId, name: name);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A0E1A), AppColors.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                ShaderMask(
                  shaderCallback: (r) => AppColors.brand.createShader(r),
                  child: const Text('MovieMatch',
                      style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const SizedBox(height: 8),
                const Text('Swipe. Discover. Match.',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                const SizedBox(height: 40),
                TextField(
                  controller: _name,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Your name',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: AppColors.pass)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.brand,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextButton(
                      onPressed: _busy ? null : _start,
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _busy
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Start Swiping',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
