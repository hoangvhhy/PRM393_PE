import 'package:prm393_pe/data/dtos/winner_dto.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'package:prm393_pe/data/implementations/mapper/winner_mapper.dart';
import 'package:prm393_pe/data/interfaces/repositories/winner_repository.dart';
import 'package:prm393_pe/domain/entities/winner_entity.dart';

class WinnerRepositoryImpl implements IWinnerRepository {
  final AppDatabase _database;

  WinnerRepositoryImpl(this._database);

  @override
  Future<int> addWinner(WinnerEntity winner) async {
    return await _database.insertWinner(winner.gameType, winner.winnerName);
  }

  @override
  Future<List<WinnerEntity>> getAllWinners() async {
    final dtos = await _database.getWinners();
    return dtos.map((d) => WinnerMapper.toEntity(WinnerDto.fromMap(d))).toList();
  }

  @override
  Future<void> clearHistory() async {
    await _database.clearWinners();
  }
}
