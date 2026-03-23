import 'package:prm393_pe/domain/entities/winner_entity.dart';

abstract class IWinnerRepository {
  Future<int> addWinner(WinnerEntity winner);
  Future<List<WinnerEntity>> getAllWinners();
  Future<void> clearHistory();
}
