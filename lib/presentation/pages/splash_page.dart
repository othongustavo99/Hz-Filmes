import 'package:flutter/material.dart';

import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.35,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation =
        Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(
              0.0,
              0.5,
              curve: Curves.easeOutBack,
            ),
          ),
        );

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainPage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Imagem ocupando toda a tela
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/image/image.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Barra de carregamento
              Positioned(
                left: 40,
                right: 40,
                bottom: 45,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.35),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF6B00),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
