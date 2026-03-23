class RedEnvelopeDto {
  final int? id;
  final String prizeName;
  final int displayOrder;

  RedEnvelopeDto({
    this.id,
    required this.prizeName,
    required this.displayOrder,
  });

  factory RedEnvelopeDto.fromMap(Map<String, dynamic> map) {
    return RedEnvelopeDto(
      id: map['id'] as int?,
      prizeName: map['prize_name'] as String,
      displayOrder: map['display_order'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'prize_name': prizeName,
      'display_order': displayOrder,
    };
  }
}
