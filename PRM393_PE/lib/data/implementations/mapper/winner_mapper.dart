import 'package:prm393_pe/data/dtos/winner_dto.dart';
import 'package:prm393_pe/domain/entities/winner_entity.dart';

class WinnerMapper {
  static WinnerEntity toEntity(WinnerDto dto) {
    return WinnerEntity(
      id: dto.id,
      gameType: dto.gameType,
      winnerName: dto.winnerName,
      createdAt: DateTime.parse(dto.createdAt),
    );
  }

  static WinnerDto toDto(WinnerEntity entity) {
    return WinnerDto(
      id: entity.id,
      gameType: entity.gameType,
      winnerName: entity.winnerName,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
