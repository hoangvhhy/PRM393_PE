import 'package:flutter/material.dart';
import 'package:prm393_pe/data/interfaces/repositories/winner_repository.dart';
import 'package:prm393_pe/domain/entities/winner_entity.dart';

class HistoryViewModel extends ChangeNotifier {
  final IWinnerRepository _winnerRepository;

  HistoryViewModel(this._winnerRepository);

  List<WinnerEntity> _winners = [];
  bool _isLoading = false;
  String? _error;

  List<WinnerEntity> get winners => _winners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _winners = await _winnerRepository.getAllWinners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _winnerRepository.clearHistory();
      _winners = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String getGameIcon(String gameType) {
    switch (gameType) {
      case 'Vòng Quay':
        return '🎡';
      case 'Random Số':
        return '🎰';
      case 'Lì Xì':
        return '🧧';
      default:
        return '🎁';
    }
  }
}
