import 'package:flutter/material.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;
  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF12082A),
            Color(0xFF1E1040),
            Color(0xFF12082A),
          ],
        ),
      ),
      child: child,
    );
  }
}
