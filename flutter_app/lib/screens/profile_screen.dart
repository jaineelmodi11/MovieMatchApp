import 'package:flutter/material.dart';
import '../services/session.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  final int userId;
  final String name;
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.userId, required this.name, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(gradient: AppColors.brand, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700))),
            Center(child: Text('User #$userId', style: const TextStyle(color: AppColors.textSecondary))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Session.clear();
                  onLogout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.pass,
                  side: const BorderSide(color: AppColors.pass),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
