import 'package:flutter/material.dart';
import 'package:prm393_pe/data/dtos/wheel_dto.dart';
import 'package:prm393_pe/domain/entities/wheel_entity.dart';

class WheelMapper {
  static WheelEntity toEntity(WheelDto dto, List<WheelSliceDto> sliceDtos) {
    return WheelEntity(
      id: dto.id,
      title: dto.title,
      spinCount: dto.spinCount,
      spinTime: dto.spinTime,
      createdAt: DateTime.parse(dto.createdAt),
      lastUsed: dto.lastUsed != null ? DateTime.parse(dto.lastUsed!) : null,
      slices: sliceDtos.map((s) => sliceToEntity(s)).toList(),
    );
  }

  static WheelSliceEntity sliceToEntity(WheelSliceDto dto) {
    return WheelSliceEntity(
      id: dto.id,
      wheelId: dto.wheelId,
      name: dto.name,
      emoji: dto.emoji,
      color: Color(dto.color),
      repeatCount: dto.repeatCount,
      probability: dto.probability,
      displayOrder: dto.displayOrder,
    );
  }

  static WheelDto toDto(WheelEntity entity) {
    return WheelDto(
      id: entity.id,
      title: entity.title,
      spinCount: entity.spinCount,
      spinTime: entity.spinTime,
      createdAt: entity.createdAt.toIso8601String(),
      lastUsed: entity.lastUsed?.toIso8601String(),
    );
  }

  static WheelSliceDto sliceToDto(WheelSliceEntity entity, int wheelId) {
    return WheelSliceDto(
      id: entity.id,
      wheelId: wheelId,
      name: entity.name,
      emoji: entity.emoji,
      color: entity.color.value,
      repeatCount: entity.repeatCount,
      probability: entity.probability,
      displayOrder: entity.displayOrder,
    );
  }
}
