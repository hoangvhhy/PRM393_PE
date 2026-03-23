import 'package:flutter/material.dart';
import 'package:prm393_pe/views/wheel/wheel_settings_screen.dart';

class WheelProbabilityScreen extends StatefulWidget {
  final List<WheelSlice> slices;
  final String? wheelTitle;

  const WheelProbabilityScreen({
    super.key,
    required this.slices,
    this.wheelTitle,
  });

  @override
  State<WheelProbabilityScreen> createState() => _WheelProbabilityScreenState();
}

class _WheelProbabilityScreenState extends State<WheelProbabilityScreen> {
  late List<WheelSlice> _slices;
  double _totalProbability = 0;

  @override
  void initState() {
    super.initState();
    _slices = List.from(widget.slices);
    _calculateTotal();
  }

  void _calculateTotal() {
    _totalProbability = _slices.fold(
      0,
      (sum, slice) => sum + (slice.probability ?? 1.0),
    );
  }

  double _getPercentage(double probability) {
    if (_totalProbability == 0) return 0;
    return (probability / _totalProbability) * 100;
  }

  void _updateProbability(int index, double value) {
    setState(() {
      _slices[index] = WheelSlice(
        name: _slices[index].name,
        emoji: _slices[index].emoji,
        color: _slices[index].color,
        repeat: _slices[index].repeat,
        probability: value,
      );
      _calculateTotal();
    });
  }

  void _resetToEqual() {
    setState(() {
      for (int i = 0; i < _slices.length; i++) {
        _slices[i] = WheelSlice(
          name: _slices[i].name,
          emoji: _slices[i].emoji,
          color: _slices[i].color,
          repeat: _slices[i].repeat,
          probability: 1.0,
        );
      }
      _calculateTotal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.wheelTitle ?? 'Vòng quay',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Text(
              'Điều chỉnh tỷ lệ',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetToEqual,
            tooltip: 'Đặt lại bằng nhau',
          ),
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: () => Navigator.pop(context, _slices),
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: _slices.isEmpty
          ? const Center(
              child: Text(
                'Chưa có phần thưởng',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : Column(
              children: [
                // Info card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Điều chỉnh tỷ lệ trúng thưởng',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tỷ lệ càng cao, cơ hội trúng càng lớn. Tổng tỷ lệ không cần bằng 100%.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Tổng tỷ lệ: ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _totalProbability.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Slices list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _slices.length,
                    itemBuilder: (context, index) {
                      final slice = _slices[index];
                      final probability = slice.probability ?? 1.0;
                      final percentage = _getPercentage(probability);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: slice.color.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: slice.color.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  slice.emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    slice.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: slice.color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: slice.color,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.white,
                                      overlayColor: slice.color.withOpacity(
                                        0.2,
                                      ),
                                    ),
                                    child: Slider(
                                      value: probability,
                                      min: 0.1,
                                      max: 10.0,
                                      divisions: 99,
                                      onChanged: (value) =>
                                          _updateProbability(index, value),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 50,
                                  child: Text(
                                    probability.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
