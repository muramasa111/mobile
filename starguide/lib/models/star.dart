import 'package:flutter/material.dart';

class Star {
  final String id;
  final String name;
  final double x;
  final double y;
  final double magnitude;
  final Color color;

  const Star({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.magnitude,
    required this.color,
  });
}
