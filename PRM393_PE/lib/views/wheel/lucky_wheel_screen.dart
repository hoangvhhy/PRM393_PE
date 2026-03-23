import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'dart:async';
import 'package:prm393_pe/services/storage_service.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'wheel_settings_screen.dart';
import 'wheel_probability_screen.dart';

class LuckyWheelScreen extends StatefulWidget {
  final int? wheelId;
  final String? wheelTitle;

  const LuckyWheelScreen({
    super.key,
    this.wheelId,
    this.wheelTitle,
  });

  @override
  State<LuckyWheelScreen> createState() => _LuckyWheelScreenState();
}

class _LuckyWheelScreenState extends State<LuckyWheelScreen> {
  final StreamController<int> _controller = StreamController<int>.broadcast();
  final TextEditingController _textController = TextEditingController();
  List<String> _items = [];
  List<WheelSlice>? _slices; // Store slices configuration
  bool _isSpinning = false;
  String? _winner;
  double _spinTime = 4; // Spin duration in seconds
  
  // For detecting multiple taps on settings button
  int _settingsTapCount = 0;
  Timer? _settingsTapTimer;

  @override
  void initState() {
    super.initState();
    if (widget.wheelId != null) {
      _loadWheelData();
    }
  }

  Future<void> _loadWheelData() async {
    if (widget.wheelId == null) return;
    
    final wheel = await AppDatabase.instance.getSavedWheel(widget.wheelId!);
    if (wheel != null) {
      _spinTime = (wheel['spin_time'] as num).toDouble();
    }

    final slicesData = await AppDatabase.instance.getWheelSlices(widget.wheelId!);
    if (slicesData.isNotEmpty) {
      _slices = slicesData.map((data) {
        return WheelSlice(
          name: data['name'] as String,
          emoji: data['emoji'] as String? ?? '',
          color: Color(data['color'] as int),
          repeat: data['repeat_count'] as int,
          probability: (data['probability'] as num?)?.toDouble() ?? 1.0,
        );
      }).toList();
      
      // Generate items list from slices
      _items = _generateItemsFromSlices(_slices!);
      setState(() {});
    }
  }

  List<String> _generateItemsFromSlices(List<WheelSlice> slices) {
    List<String> result = [];
    int maxRepeat = slices.isEmpty ? 1 : slices.map((s) => s.repeat).reduce((a, b) => a > b ? a : b);
    
    for (int i = 0; i < maxRepeat; i++) {
      for (var slice in slices) {
        if (i < slice.repeat) {
          result.add(slice.name);
        }
      }
    }
    return result;
  }

  Future<void> _saveWheelData() async {
    if (widget.wheelId == null || _slices == null) return;

    // Clear old slices
    await AppDatabase.instance.clearWheelSlices(widget.wheelId!);

    // Save new slices with probability
    for (int i = 0; i < _slices!.length; i++) {
      final slice = _slices![i];
      await AppDatabase.instance.insertWheelSlice(
        widget.wheelId!,
        slice.name,
        slice.emoji,
        slice.color.value,
        slice.repeat,
        i,
        probability: slice.probability ?? 1.0,
      );
    }

    // Update spin time
    await AppDatabase.instance.updateSavedWheel(
      widget.wheelId!,
      widget.wheelTitle ?? 'Untitled wheel',
      _spinTime,
    );
  }

  @override
  void dispose() {
    _controller.close();
    _textController.dispose();
    _settingsTapTimer?.cancel();
    super.dispose();
  }

  void _onSettingsTap() {
    _settingsTapCount++;
    
    // Cancel previous timer
    _settingsTapTimer?.cancel();
    
    // Set timer to reset tap count after 500ms
    _settingsTapTimer = Timer(const Duration(milliseconds: 500), () {
      if (_settingsTapCount >= 3) {
        // Open probability screen
        _openProbabilitySettings();
      } else if (_settingsTapCount == 1) {
        // Open normal settings
        _openSettings();
      }
      _settingsTapCount = 0;
    });
  }

  Future<void> _openProbabilitySettings() async {
    if (_slices == null || _slices!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm phần thưởng trước')),
      );
      return;
    }

    final result = await Navigator.push<List<WheelSlice>>(
      context,
      MaterialPageRoute(
        builder: (_) => WheelProbabilityScreen(
          slices: _slices!,
          wheelTitle: widget.wheelTitle,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _slices = result;
        _items = _generateItemsFromSlices(_slices!);
      });
      
      if (widget.wheelId != null) {
        await _saveWheelData();
      }
    }
  }

  void _openSettings() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => WheelSettingsScreen(
          initialItems: _items,
          initialSlices: _slices,
          initialSpinTime: _spinTime,
          wheelTitle: widget.wheelTitle,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _items = result['items'] as List<String>;
        _slices = result['slices'] as List<WheelSlice>?;
        _spinTime = result['spinTime'] as double? ?? 4;
      });
      
      // Save to database if wheelId exists
      if (widget.wheelId != null) {
        await _saveWheelData();
      }
    }
  }

  void _addItem() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _items.add(_textController.text.trim());
        _textController.clear();
      });
    }
  }

  void _spin() {
    if (_items.length < 2 || _isSpinning) return;
    
    setState(() {
      _isSpinning = true;
      _winner = null;
    });

    // Use weighted random selection based on probability
    final selected = _getWeightedRandomIndex();
    _controller.add(selected);

    // Use the spin time from settings
    final spinDuration = Duration(milliseconds: (_spinTime * 1000).round());
    
    Future.delayed(spinDuration, () async {
      if (mounted) {
        setState(() {
          _winner = _items[selected];
          _isSpinning = false;
        });
        
        // Increment spin count in database
        if (widget.wheelId != null) {
          await AppDatabase.instance.incrementSpinCount(widget.wheelId!);
        }
        
        StorageService.saveWinner('Vòng Quay', _winner!);
        _showWinnerDialog();
      }
    });
  }

  int _getWeightedRandomIndex() {
    // If no slices or no probability set, use uniform random
    if (_slices == null || _slices!.isEmpty) {
      return DateTime.now().millisecondsSinceEpoch % _items.length;
    }

    // Build cumulative weights for each item
    final List<double> cumulativeWeights = [];
    double totalWeight = 0;

    for (int i = 0; i < _items.length; i++) {
      final itemName = _items[i];
      // Find the slice for this item
      final slice = _slices!.firstWhere(
        (s) => s.name == itemName,
        orElse: () => WheelSlice(name: itemName, probability: 1.0),
      );
      
      final weight = slice.probability ?? 1.0;
      totalWeight += weight;
      cumulativeWeights.add(totalWeight);
    }

    // Generate random number between 0 and totalWeight
    final random = (DateTime.now().microsecondsSinceEpoch % 1000000) / 1000000.0;
    final randomValue = random * totalWeight;

    // Find the index where randomValue falls
    for (int i = 0; i < cumulativeWeights.length; i++) {
      if (randomValue <= cumulativeWeights[i]) {
        return i;
      }
    }

    // Fallback (should never reach here)
    return 0;
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Chúc Mừng! 🎉'),
        content: Text(
          'Người trúng thưởng:\n$_winner',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _items.remove(_winner);
                
                // Update slices configuration
                if (_slices != null) {
                  final slice = _slices!.firstWhere(
                    (s) => s.name == _winner,
                    orElse: () => WheelSlice(name: ''),
                  );
                  if (slice.name.isNotEmpty) {
                    if (slice.repeat > 1) {
                      slice.repeat--;
                    } else {
                      _slices!.remove(slice);
                    }
                  }
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Xóa khỏi vòng quay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Giữ lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wheelTitle ?? '🎡 Vòng Quay May Mắn'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: _onSettingsTap,
            tooltip: 'Cài đặt (nhấn 3 lần để điều chỉnh tỷ lệ)',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Wheel - Always show, even when empty
            SizedBox(
              height: 300,
              child: _items.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Vòng Quay\nTrống',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : _items.length == 1
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.primaries[0],
                            border: Border.all(
                              color: Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _items[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : FortuneWheel(
                          animateFirst: false,
                          selected: _controller.stream,
                          items: _items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            
                            // Find the color from slices if available
                            Color itemColor = Colors.primaries[index % Colors.primaries.length];
                            if (_slices != null) {
                              final slice = _slices!.firstWhere(
                                (s) => s.name == item,
                                orElse: () => WheelSlice(name: item, color: itemColor),
                              );
                              itemColor = slice.color;
                            }
                            
                            return FortuneItem(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: FortuneItemStyle(
                                color: itemColor,
                              ),
                            );
                          }).toList(),
                        ),
            ),
            
            const SizedBox(height: 30),
            
            // Spin Button - Always show
            ElevatedButton(
              onPressed: (_items.length >= 2 && !_isSpinning) ? _spin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: Text(_isSpinning ? 'Đang Quay...' : '🎯 QUAY NGAY!'),
            ),
            
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Nhấn nút ⋮ để thêm phần thưởng',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              )
            else if (_items.length < 2)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Thêm thêm 1 mục nữa để quay',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
