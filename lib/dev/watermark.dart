import 'package:flutter/material.dart';

class WatermarkWrapper extends StatelessWidget {
  final Widget child;

  const WatermarkWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Content
        child,

        // Watermark
        Positioned(
          bottom: 20,
          right: 20,
          child: Opacity(
            opacity: 0.5, 
            child: Transform.rotate(
              angle: -0.2, 
              child: const Text(
                'cloudsoftware.tn',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}