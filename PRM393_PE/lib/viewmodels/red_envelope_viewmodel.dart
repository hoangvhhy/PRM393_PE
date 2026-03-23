import 'package:flutter/material.dart';
import 'package:prm393_pe/data/interfaces/repositories/red_envelope_repository.dart';
import 'package:prm393_pe/domain/entities/red_envelope_entity.dart';

class RedEnvelopeViewModel extends ChangeNotifier {
  final IRedEnvelopeRepository _repository;

  RedEnvelopeViewModel(this._repository);

  List<RedEnvelopeEntity> _prizes = [];
  bool _isLoading = false;
  String? _error;

  List<RedEnvelopeEntity> get prizes => _prizes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrizes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prizes = await _repository.getAllPrizes();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPrize(String prizeName) async {
    try {
      final prize = RedEnvelopeEntity(
        prizeName: prizeName,
        displayOrder: _prizes.length,
      );
      await _repository.addPrize(prize);
      await loadPrizes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updatePrize(int id, String newName) async {
    try {
      final prize = _prizes.firstWhere((p) => p.id == id);
      final updated = RedEnvelopeEntity(
        id: id,
        prizeName: newName,
        displayOrder: prize.displayOrder,
      );
      await _repository.updatePrize(updated);
      await loadPrizes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePrize(int id) async {
    try {
      await _repository.deletePrize(id);
      await loadPrizes();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAllPrizes();
      _prizes = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void reorderPrizes(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = _prizes.removeAt(oldIndex);
    _prizes.insert(newIndex, item);
    
    // Update display order
    for (int i = 0; i < _prizes.length; i++) {
      _prizes[i] = RedEnvelopeEntity(
        id: _prizes[i].id,
        prizeName: _prizes[i].prizeName,
        displayOrder: i,
      );
    }
    
    _repository.reorderPrizes(_prizes);
    notifyListeners();
  }
}
