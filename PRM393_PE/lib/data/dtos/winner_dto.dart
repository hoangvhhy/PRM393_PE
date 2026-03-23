class WinnerDto {
  final int? id;
  final String gameType;
  final String winnerName;
  final String createdAt;

  WinnerDto({
    this.id,
    required this.gameType,
    required this.winnerName,
    required this.createdAt,
  });

  factory WinnerDto.fromMap(Map<String, dynamic> map) {
    return WinnerDto(
      id: map['id'] as int?,
      gameType: map['game_type'] as String,
      winnerName: map['winner_name'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'game_type': gameType,
      'winner_name': winnerName,
      'created_at': createdAt,
    };
  }
}
