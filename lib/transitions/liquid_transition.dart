import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Custom clipper para simular un efecto "líquido"
class LiquidClipper extends CustomClipper<Path> {
  final double progress;

  LiquidClipper(this.progress);

  @override
  Path getClip(Size size) {
    final path = Path();
    // Efecto: se revela la pantalla de derecha a izquierda con una curva
    double offset = size.width * (1 - progress);
    path.moveTo(offset, 0);
    path.quadraticBezierTo(0, size.height / 2, offset, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// Función de transición que utiliza el LiquidClipper
Widget liquidTransition(
    BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, childWidget) {
      return ClipPath(
        clipper: LiquidClipper(animation.value),
        child: childWidget,
      );
    },
    child: child,
  );
}

// Custom transition para GetX
class LiquidCustomTransition extends CustomTransition {
  @override
  Widget buildTransition(BuildContext context, Curve? curve, Alignment? alignment, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve ?? Curves.linear);
    return liquidTransition(context, curvedAnimation, secondaryAnimation, child);
  }
}
