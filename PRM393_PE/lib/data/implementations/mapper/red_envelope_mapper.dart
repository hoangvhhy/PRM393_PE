import 'package:prm393_pe/data/dtos/red_envelope_dto.dart';
import 'package:prm393_pe/domain/entities/red_envelope_entity.dart';

class RedEnvelopeMapper {
  static RedEnvelopeEntity toEntity(RedEnvelopeDto dto) {
    return RedEnvelopeEntity(
      id: dto.id,
      prizeName: dto.prizeName,
      displayOrder: dto.displayOrder,
    );
  }

  static RedEnvelopeDto toDto(RedEnvelopeEntity entity) {
    return RedEnvelopeDto(
      id: entity.id,
      prizeName: entity.prizeName,
      displayOrder: entity.displayOrder,
    );
  }
}
