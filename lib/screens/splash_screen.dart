import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/dark_background.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin { // ← ubah jadi TickerProviderStateMixin
  late AnimationController _controller;
  late AnimationController _loadingController; // ← tambah ini
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _loadingAnim; // ← tambah ini

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Controller untuk fade & scale (1.4 detik)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Controller loading bar (3 detik, sama dengan delay navigate)
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _loadingAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    _loadingController.forward(); // ← jalankan loading bar

    Future.delayed(const Duration(seconds: 3), () async {
      final token = await ApiService.getToken();
      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _loadingController.dispose(); // ← dispose juga
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: DarkBackground(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 40,
                      left: 160,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.blueDark, AppColors.blue],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blue.withOpacity(0.5),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'VG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                              ),
                              children: [
                                TextSpan(text: 'VH', style: TextStyle(color: Colors.white)),
                                TextSpan(text: 'G', style: TextStyle(color: AppColors.blue)),
                                TextSpan(text: 'H', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'STYLE WITHOUT LIMITS',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: AppColors.blue, size: 10),
                                SizedBox(width: 6),
                                Text(
                                  'NEW COLLECTION 2026',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 10,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ── LOADING BAR ANIMASI ──
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 40,
                    ),
                    child: Column(
                      children: [
                        // Background bar (abu-abu) + bar berjalan (biru-hijau)
                        SizedBox(
                          width: 90,
                          height: 3,
                          child: AnimatedBuilder(
                            animation: _loadingAnim,
                            builder: (context, _) {
                              return Stack(
                                children: [
                                  // Background
                                  Container(
                                    width: 90,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  // Bar yang berjalan
                                  Container(
                                    width: 100 * _loadingAnim.value,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.blue, AppColors.green],
                                      ),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Memuat pengalaman terbaik...',
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}