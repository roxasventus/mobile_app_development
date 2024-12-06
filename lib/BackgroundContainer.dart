import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final String imagePath;
  final double scale;

  const BackgroundContainer({
    Key? key,
    required this.child,
    required this.imagePath,
    this.scale = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.scale(
            scale: scale,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
