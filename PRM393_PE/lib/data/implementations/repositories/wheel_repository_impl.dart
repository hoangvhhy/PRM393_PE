import 'package:prm393_pe/data/dtos/wheel_dto.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'package:prm393_pe/data/implementations/mapper/wheel_mapper.dart';
import 'package:prm393_pe/data/interfaces/repositories/wheel_repository.dart';
import 'package:prm393_pe/domain/entities/wheel_entity.dart';

class WheelRepositoryImpl implements IWheelRepository {
  final AppDatabase _database;

  WheelRepositoryImpl(this._database);

  @override
  Future<int> createWheel(WheelEntity wheel) async {
    final dto = WheelMapper.toDto(wheel);
    return await _database.insertSavedWheel(dto.title, dto.spinTime);
  }

  @override
  Future<List<WheelEntity>> getAllWheels() async {
    final dtos = await _database.getSavedWheels();
    final List<WheelEntity> wheels = [];
    
    for (var dtoMap in dtos) {
      final dto = WheelDto.fromMap(dtoMap);
      final sliceDtos = await _database.getWheelSlices(dto.id!);
      final slices = sliceDtos.map((s) => WheelSliceDto.fromMap(s)).toList();
      wheels.add(WheelMapper.toEntity(dto, slices));
    }
    
    return wheels;
  }

  @override
  Future<WheelEntity?> getWheel(int id) async {
    final dtoMap = await _database.getSavedWheel(id);
    if (dtoMap == null) return null;
    
    final dto = WheelDto.fromMap(dtoMap);
    final sliceDtos = await _database.getWheelSlices(id);
    final slices = sliceDtos.map((s) => WheelSliceDto.fromMap(s)).toList();
    
    return WheelMapper.toEntity(dto, slices);
  }

  @override
  Future<void> updateWheel(WheelEntity wheel) async {
    if (wheel.id == null) return;
    await _database.updateSavedWheel(wheel.id!, wheel.title, wheel.spinTime);
  }

  @override
  Future<void> deleteWheel(int id) async {
    await _database.deleteSavedWheel(id);
  }

  @override
  Future<void> incrementSpinCount(int wheelId) async {
    await _database.incrementSpinCount(wheelId);
  }

  @override
  Future<void> saveSlices(int wheelId, List<WheelSliceEntity> slices) async {
    await _database.clearWheelSlices(wheelId);
    
    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      await _database.insertWheelSlice(
        wheelId,
        slice.name,
        slice.emoji,
        slice.color.value,
        slice.repeatCount,
        i,
      );
    }
  }

  @override
  Future<List<WheelSliceEntity>> getSlices(int wheelId) async {
    final dtos = await _database.getWheelSlices(wheelId);
    return dtos.map((d) => WheelMapper.sliceToEntity(WheelSliceDto.fromMap(d))).toList();
  }
}
