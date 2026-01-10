import 'package:flutter/material.dart';

/// Smooth page transition with fade and slide effects
class SmoothPageTransition extends PageRouteBuilder {
  final Widget page;
  final Duration duration;

  SmoothPageTransition({
    required this.page,
    this.duration = const Duration(milliseconds: 600),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => page,
         transitionDuration: duration,
         reverseTransitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Fade out old page
           final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
             ),
           );

           // Fade in new page
           final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
             ),
           );

           // Slide up new page
           final slideUp =
               Tween<Offset>(
                 begin: const Offset(0.0, 0.3),
                 end: Offset.zero,
               ).animate(
                 CurvedAnimation(
                   parent: animation,
                   curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                 ),
               );

           // Scale old page slightly
           final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(
             CurvedAnimation(
               parent: animation,
               curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
             ),
           );

           return Stack(
             children: [
               // Old page (fading out and scaling down)
               FadeTransition(
                 opacity: fadeOut,
                 child: ScaleTransition(
                   scale: scaleOut,
                   child: Container(
                     color: Theme.of(context).colorScheme.surface,
                   ),
                 ),
               ),
               // New page (sliding up and fading in)
               SlideTransition(
                 position: slideUp,
                 child: FadeTransition(opacity: fadeIn, child: child),
               ),
             ],
           );
         },
       );
}
