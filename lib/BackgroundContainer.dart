import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final String imagePath;
  final double scale;
  final Widget child; // child 파라미터 추가

  const BackgroundContainer({
    Key? key,
    required this.imagePath,
    this.scale = 1.0,
    required this.child, // child 파라미터 required
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
