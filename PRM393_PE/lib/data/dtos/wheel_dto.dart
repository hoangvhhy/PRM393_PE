class WheelDto {
  final int? id;
  final String title;
  final int spinCount;
  final double spinTime;
  final String createdAt;
  final String? lastUsed;

  WheelDto({
    this.id,
    required this.title,
    required this.spinCount,
    required this.spinTime,
    required this.createdAt,
    this.lastUsed,
  });

  factory WheelDto.fromMap(Map<String, dynamic> map) {
    return WheelDto(
      id: map['id'] as int?,
      title: map['title'] as String,
      spinCount: map['spin_count'] as int,
      spinTime: (map['spin_time'] as num).toDouble(),
      createdAt: map['created_at'] as String,
      lastUsed: map['last_used'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'spin_count': spinCount,
      'spin_time': spinTime,
      'created_at': createdAt,
      if (lastUsed != null) 'last_used': lastUsed,
    };
  }
}

class WheelSliceDto {
  final int? id;
  final int wheelId;
  final String name;
  final String emoji;
  final int color;
  final int repeatCount;
  final double probability;
  final int displayOrder;

  WheelSliceDto({
    this.id,
    required this.wheelId,
    required this.name,
    required this.emoji,
    required this.color,
    required this.repeatCount,
    this.probability = 1.0,
    required this.displayOrder,
  });

  factory WheelSliceDto.fromMap(Map<String, dynamic> map) {
    return WheelSliceDto(
      id: map['id'] as int?,
      wheelId: map['wheel_id'] as int,
      name: map['name'] as String,
      emoji: map['emoji'] as String? ?? '',
      color: map['color'] as int,
      repeatCount: map['repeat_count'] as int,
      probability: (map['probability'] as num?)?.toDouble() ?? 1.0,
      displayOrder: map['display_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'wheel_id': wheelId,
      'name': name,
      'emoji': emoji,
      'color': color,
      'repeat_count': repeatCount,
      'probability': probability,
      'display_order': displayOrder,
    };
  }
}
