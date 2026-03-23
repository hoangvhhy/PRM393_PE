import 'package:flutter/material.dart';
import 'package:prm393_pe/data/interfaces/repositories/wheel_repository.dart';
import 'package:prm393_pe/domain/entities/wheel_entity.dart';

class WheelLibraryViewModel extends ChangeNotifier {
  final IWheelRepository _wheelRepository;

  WheelLibraryViewModel(this._wheelRepository);

  List<WheelEntity> _wheels = [];
  bool _isLoading = false;
  String? _error;

  List<WheelEntity> get wheels => _wheels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWheels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wheels = await _wheelRepository.getAllWheels();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int?> createWheel(String title) async {
    try {
      final wheel = WheelEntity(
        title: title,
        createdAt: DateTime.now(),
      );
      final id = await _wheelRepository.createWheel(wheel);
      await loadWheels();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> deleteWheel(int id) async {
    try {
      await _wheelRepository.deleteWheel(id);
      await loadWheels();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> renameWheel(int id, String newTitle) async {
    try {
      final wheel = _wheels.firstWhere((w) => w.id == id);
      final updated = WheelEntity(
        id: wheel.id,
        title: newTitle,
        spinCount: wheel.spinCount,
        spinTime: wheel.spinTime,
        createdAt: wheel.createdAt,
        lastUsed: wheel.lastUsed,
        slices: wheel.slices,
      );
      await _wheelRepository.updateWheel(updated);
      await loadWheels();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'Never';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
    return '${(diff.inDays / 365).floor()} years ago';
  }
}
