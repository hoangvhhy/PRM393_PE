import 'package:prm393_pe/domain/entities/wheel_entity.dart';

abstract class IWheelRepository {
  Future<int> createWheel(WheelEntity wheel);
  Future<List<WheelEntity>> getAllWheels();
  Future<WheelEntity?> getWheel(int id);
  Future<void> updateWheel(WheelEntity wheel);
  Future<void> deleteWheel(int id);
  Future<void> incrementSpinCount(int wheelId);
  
  Future<void> saveSlices(int wheelId, List<WheelSliceEntity> slices);
  Future<List<WheelSliceEntity>> getSlices(int wheelId);
}
