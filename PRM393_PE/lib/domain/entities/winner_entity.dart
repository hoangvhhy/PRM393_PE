class WinnerEntity {
  final int? id;
  final String gameType;
  final String winnerName;
  final DateTime createdAt;

  WinnerEntity({
    this.id,
    required this.gameType,
    required this.winnerName,
    required this.createdAt,
  });
}
