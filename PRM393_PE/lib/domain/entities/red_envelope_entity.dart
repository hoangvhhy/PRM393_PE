class RedEnvelopeEntity {
  final int? id;
  final String prizeName;
  final int displayOrder;

  RedEnvelopeEntity({
    this.id,
    required this.prizeName,
    this.displayOrder = 0,
  });
}
