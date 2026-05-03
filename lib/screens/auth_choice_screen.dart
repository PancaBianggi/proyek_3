import 'package:flutter/material.dart';
import '../widgets/dark_background.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1F),
      body: DarkBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),

                // Pertanyaan besar
                const Text(
                  'APAKAH\nSUDAH ADA\nAKUN?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                    letterSpacing: 1,
                  ),
                ),

                const Spacer(flex: 3),

                // Tombol LOGIN
                PrimaryButton(
                  text: 'LOGIN',
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                ),
                const SizedBox(height: 14),

                // Tombol BUAT AKUN
                SecondaryButton(
                  text: 'BUAT AKUN',
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}