import 'package:flutter/material.dart';

class WheelEntity {
  final int? id;
  final String title;
  final int spinCount;
  final double spinTime;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final List<WheelSliceEntity> slices;

  WheelEntity({
    this.id,
    required this.title,
    this.spinCount = 0,
    this.spinTime = 4.0,
    required this.createdAt,
    this.lastUsed,
    this.slices = const [],
  });
}

class WheelSliceEntity {
  final int? id;
  final int? wheelId;
  final String name;
  final String emoji;
  final Color color;
  final int repeatCount;
  final double probability;
  final int displayOrder;

  WheelSliceEntity({
    this.id,
    this.wheelId,
    required this.name,
    this.emoji = '',
    required this.color,
    this.repeatCount = 1,
    this.probability = 1.0,
    this.displayOrder = 0,
  });
}
