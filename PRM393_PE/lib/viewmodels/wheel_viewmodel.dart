import 'package:flutter/material.dart';
import 'package:prm393_pe/data/interfaces/repositories/wheel_repository.dart';
import 'package:prm393_pe/data/interfaces/repositories/winner_repository.dart';
import 'package:prm393_pe/domain/entities/wheel_entity.dart';
import 'package:prm393_pe/domain/entities/winner_entity.dart';

class WheelViewModel extends ChangeNotifier {
  final IWheelRepository _wheelRepository;
  final IWinnerRepository _winnerRepository;

  WheelViewModel(this._wheelRepository, this._winnerRepository);

  WheelEntity? _wheel;
  List<String> _items = [];
  bool _isSpinning = false;
  String? _winner;
  String? _error;

  WheelEntity? get wheel => _wheel;
  List<String> get items => _items;
  bool get isSpinning => _isSpinning;
  String? get winner => _winner;
  String? get error => _error;

  Future<void> loadWheel(int wheelId) async {
    try {
      _wheel = await _wheelRepository.getWheel(wheelId);
      if (_wheel != null) {
        _items = _generateItemsFromSlices(_wheel!.slices);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<String> _generateItemsFromSlices(List<WheelSliceEntity> slices) {
    List<String> result = [];
    if (slices.isEmpty) return result;
    
    int maxRepeat = slices.map((s) => s.repeatCount).reduce((a, b) => a > b ? a : b);
    
    for (int i = 0; i < maxRepeat; i++) {
      for (var slice in slices) {
        if (i < slice.repeatCount) {
          result.add(slice.name);
        }
      }
    }
    return result;
  }

  void startSpin() {
    if (_items.length < 2 || _isSpinning) return;
    
    _isSpinning = true;
    _winner = null;
    notifyListeners();
  }

  Future<void> completeSpin(String winnerName) async {
    _winner = winnerName;
    _isSpinning = false;
    notifyListeners();

    // Save to database
    if (_wheel?.id != null) {
      await _wheelRepository.incrementSpinCount(_wheel!.id!);
    }
    
    await _winnerRepository.addWinner(WinnerEntity(
      gameType: 'Vòng Quay',
      winnerName: winnerName,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> removeWinner(String winnerName) async {
    _items.remove(winnerName);
    
    // Update slices in database
    if (_wheel?.id != null && _wheel!.slices.isNotEmpty) {
      final updatedSlices = List<WheelSliceEntity>.from(_wheel!.slices);
      final sliceIndex = updatedSlices.indexWhere((s) => s.name == winnerName);
      
      if (sliceIndex != -1) {
        final slice = updatedSlices[sliceIndex];
        if (slice.repeatCount > 1) {
          updatedSlices[sliceIndex] = WheelSliceEntity(
            id: slice.id,
            wheelId: slice.wheelId,
            name: slice.name,
            emoji: slice.emoji,
            color: slice.color,
            repeatCount: slice.repeatCount - 1,
            displayOrder: slice.displayOrder,
          );
        } else {
          updatedSlices.removeAt(sliceIndex);
        }
        
        await _wheelRepository.saveSlices(_wheel!.id!, updatedSlices);
        _wheel = WheelEntity(
          id: _wheel!.id,
          title: _wheel!.title,
          spinCount: _wheel!.spinCount,
          spinTime: _wheel!.spinTime,
          createdAt: _wheel!.createdAt,
          lastUsed: _wheel!.lastUsed,
          slices: updatedSlices,
        );
      }
    }
    
    notifyListeners();
  }

  Future<void> updateWheelSettings(List<WheelSliceEntity> slices, double spinTime) async {
    if (_wheel?.id == null) return;
    
    await _wheelRepository.saveSlices(_wheel!.id!, slices);
    
    _wheel = WheelEntity(
      id: _wheel!.id,
      title: _wheel!.title,
      spinCount: _wheel!.spinCount,
      spinTime: spinTime,
      createdAt: _wheel!.createdAt,
      lastUsed: _wheel!.lastUsed,
      slices: slices,
    );
    
    await _wheelRepository.updateWheel(_wheel!);
    _items = _generateItemsFromSlices(slices);
    notifyListeners();
  }
}
