import 'package:flutter/material.dart';

class SlideTransitionPage extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;

  SlideTransitionPage({
    required this.page,
    this.direction = SlideDirection.fromRight,
  }) : super(
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case SlideDirection.fromRight:
                begin = const Offset(1.0, 0.0);
                break;
              case SlideDirection.fromBottom:
                begin = const Offset(0.0, 1.0);
                break;
              case SlideDirection.fromLeft:
                begin = const Offset(-1.0, 0.0);
                break;
            }

            const end = Offset.zero;
            const curve = Curves.easeOutCubic;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            final offsetAnimation = animation.drive(tween);

            // Fade + Slide
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
        );
}

enum SlideDirection { fromRight, fromLeft, fromBottom }