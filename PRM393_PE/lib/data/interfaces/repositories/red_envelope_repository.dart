import 'package:prm393_pe/domain/entities/red_envelope_entity.dart';

abstract class IRedEnvelopeRepository {
  Future<List<RedEnvelopeEntity>> getAllPrizes();
  Future<int> addPrize(RedEnvelopeEntity prize);
  Future<void> updatePrize(RedEnvelopeEntity prize);
  Future<void> deletePrize(int id);
  Future<void> clearAllPrizes();
  Future<void> reorderPrizes(List<RedEnvelopeEntity> prizes);
}
