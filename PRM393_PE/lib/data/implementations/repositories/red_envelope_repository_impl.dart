import 'package:prm393_pe/data/dtos/red_envelope_dto.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'package:prm393_pe/data/implementations/mapper/red_envelope_mapper.dart';
import 'package:prm393_pe/data/interfaces/repositories/red_envelope_repository.dart';
import 'package:prm393_pe/domain/entities/red_envelope_entity.dart';

class RedEnvelopeRepositoryImpl implements IRedEnvelopeRepository {
  final AppDatabase _database;

  RedEnvelopeRepositoryImpl(this._database);

  @override
  Future<List<RedEnvelopeEntity>> getAllPrizes() async {
    final dtos = await _database.getRedEnvelopePrizes();
    return dtos.map((d) => RedEnvelopeMapper.toEntity(RedEnvelopeDto.fromMap(d))).toList();
  }

  @override
  Future<int> addPrize(RedEnvelopeEntity prize) async {
    return await _database.insertRedEnvelopePrize(prize.prizeName, prize.displayOrder);
  }

  @override
  Future<void> updatePrize(RedEnvelopeEntity prize) async {
    if (prize.id == null) return;
    await _database.updateRedEnvelopePrize(prize.id!, prize.prizeName);
  }

  @override
  Future<void> deletePrize(int id) async {
    await _database.deleteRedEnvelopePrize(id);
  }

  @override
  Future<void> clearAllPrizes() async {
    await _database.clearRedEnvelopePrizes();
  }

  @override
  Future<void> reorderPrizes(List<RedEnvelopeEntity> prizes) async {
    final dtos = prizes.map((e) => RedEnvelopeMapper.toDto(e).toMap()).toList();
    await _database.reorderRedEnvelopePrizes(dtos);
  }
}
