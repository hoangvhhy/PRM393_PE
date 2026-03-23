import 'package:flutter/material.dart';
import 'dart:math' as math;

class WheelSlice {
  String name;
  String emoji;
  Color color;
  int repeat;
  double? probability;

  WheelSlice({
    required this.name,
    this.emoji = '',
    Color? color,
    this.repeat = 1,
    this.probability,
  }) : color = color ?? Colors.primaries[math.Random().nextInt(Colors.primaries.length)];
}

class WheelSettingsScreen extends StatefulWidget {
  final List<String> initialItems;
  final List<WheelSlice>? initialSlices;
  final double? initialSpinTime;
  final String? wheelTitle;

  const WheelSettingsScreen({
    super.key, 
    required this.initialItems,
    this.initialSlices,
    this.initialSpinTime,
    this.wheelTitle,
  });

  @override
  State<WheelSettingsScreen> createState() => _WheelSettingsScreenState();
}

class _WheelSettingsScreenState extends State<WheelSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _titleController;
  List<WheelSlice> _slices = [];
  int _sliceRepeat = 1;
  double _spinTime = 4;
  List<Color> _colorPalette = [
    const Color(0xFF4CAF50),
    const Color(0xFF00BCD4),
    const Color(0xFF2196F3),
    const Color(0xFF3F51B5),
    const Color(0xFF9C27B0),
    const Color(0xFFE91E63),
    const Color(0xFFF44336),
    const Color(0xFFFF5722),
    const Color(0xFFFF9800),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize title controller with wheel title or default
    _titleController = TextEditingController(
      text: widget.wheelTitle ?? 'Vòng quay mới'
    );
    
    // Load saved settings
    _spinTime = widget.initialSpinTime ?? 4;
    
    // If we have saved slices configuration, use it
    if (widget.initialSlices != null && widget.initialSlices!.isNotEmpty) {
      _slices = List.from(widget.initialSlices!);
    } 
    // Otherwise, convert initial items to slices
    else if (widget.initialItems.isNotEmpty) {
      final Map<String, int> itemCounts = {};
      for (var item in widget.initialItems) {
        itemCounts[item] = (itemCounts[item] ?? 0) + 1;
      }
      int colorIndex = 0;
      _slices = itemCounts.entries.map((e) {
        final slice = WheelSlice(
          name: e.key,
          emoji: _getEmojiForFood(e.key),
          color: _colorPalette[colorIndex % _colorPalette.length],
          repeat: e.value,
        );
        colorIndex++;
        return slice;
      }).toList();
    }
    // If empty, leave _slices empty - user will add items manually
  }

  String _getEmojiForFood(String name) {
    // Try to match common food names with emojis
    final lowerName = name.toLowerCase();
    if (lowerName.contains('soup')) return '🍜';
    if (lowerName.contains('sandwich')) return '🥪';
    if (lowerName.contains('steak')) return '🥩';
    if (lowerName.contains('chinese')) return '🥡';
    if (lowerName.contains('bbq')) return '🍗';
    if (lowerName.contains('pasta')) return '🍝';
    if (lowerName.contains('hot dog')) return '🌭';
    if (lowerName.contains('salad')) return '🥗';
    if (lowerName.contains('bacon')) return '🥓';
    if (lowerName.contains('sushi')) return '🍣';
    return '🎁'; // Default emoji
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _addSlice() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _EditSliceDialog(
        initialName: '',
        initialEmoji: '🎁',
      ),
    );

    if (result != null) {
      setState(() {
        final colorIndex = _slices.length % _colorPalette.length;
        _slices.add(WheelSlice(
          name: result['name']!,
          emoji: result['emoji'] ?? '🎁',
          color: _colorPalette[colorIndex],
        ));
      });
    }
  }

  void _shuffleSlices() {
    setState(() {
      _slices.shuffle();
    });
  }

  void _sortSlices() {
    setState(() {
      _slices.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _deleteSlice(int index) {
    setState(() {
      _slices.removeAt(index);
    });
  }

  void _editSlice(int index) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _EditSliceDialog(
        initialName: _slices[index].name,
        initialEmoji: _slices[index].emoji,
      ),
    );

    if (result != null) {
      setState(() {
        _slices[index].name = result['name']!;
        _slices[index].emoji = result['emoji'] ?? '';
      });
    }
  }

  void _updateRepeat(int index, int newRepeat) {
    if (newRepeat < 1) return;
    setState(() {
      _slices[index].repeat = newRepeat;
    });
  }

  List<String> _generateFinalList() {
    List<String> result = [];
    
    // Find the maximum repeat count
    int maxRepeat = _slices.isEmpty ? 1 : _slices.map((s) => s.repeat).reduce((a, b) => a > b ? a : b);
    
    // Interleave items: 1,2,3,1,2,3,1,2,3...
    for (int i = 0; i < maxRepeat; i++) {
      for (var slice in _slices) {
        if (i < slice.repeat) {
          result.add(slice.name);
        }
      }
    }
    
    return result;
  }

  Widget _buildSliderControl(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    Color valueColor,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              displayValue,
              style: TextStyle(
                color: valueColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: valueColor,
            inactiveTrackColor: Colors.white24,
            thumbColor: Colors.white,
            overlayColor: valueColor.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
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
        title: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {
                'items': _generateFinalList(),
                'slices': _slices,
                'spinTime': _spinTime,
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                children: [
                  const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top section - Title and Preview
            Container(
              color: const Color(0xFF2C2C2C),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titleController.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Preview and Controls side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wheel Preview
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preview',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 140,
                            height: 140,
                            child: CustomPaint(
                              painter: WheelPainter(_slices),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Controls
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Slice repeat
                            _buildSliderControl(
                              'Slice repeat',
                              _sliceRepeat.toDouble(),
                              1,
                              10,
                              _sliceRepeat.toString(),
                              const Color(0xFF4CAF50),
                              (value) {
                                setState(() {
                                  _sliceRepeat = value.round();
                                  // Apply to all slices
                                  for (var slice in _slices) {
                                    slice.repeat = _sliceRepeat;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            
                            // Spin time
                            _buildSliderControl(
                              'Spin time',
                              _spinTime,
                              1,
                              10,
                              '${_spinTime.round()}x',
                              const Color(0xFF4CAF50),
                              (value) => setState(() => _spinTime = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom section - Slices
            Container(
              color: const Color(0xFF1E1E1E),
              child: Column(
                children: [
                  // Slices header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Slices',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shuffle, color: Color(0xFF4CAF50)),
                              onPressed: _shuffleSlices,
                            ),
                            IconButton(
                              icon: const Icon(Icons.sort_by_alpha, color: Color(0xFF4CAF50)),
                              onPressed: _sortSlices,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFF4CAF50)),
                              onPressed: _addSlice,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Slices list
                  _slices.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                size: 80,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có phần thưởng',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nhấn nút ➕ để thêm',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: _slices.length,
                          itemBuilder: (context, index) {
                            final slice = _slices[index];
                            return Dismissible(
                              key: Key('${slice.name}_$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white, size: 30),
                              ),
                              onDismissed: (direction) {
                                setState(() {
                                  _slices.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã xóa ${slice.name}'),
                                    action: SnackBarAction(
                                      label: 'Hoàn tác',
                                      onPressed: () {
                                        setState(() {
                                          _slices.insert(index, slice);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: slice.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => _editSlice(index),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                slice.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              slice.emoji,
                                              style: const TextStyle(fontSize: 20),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.edit, color: Colors.white70, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Repeat count controls
                                    if (slice.repeat > 1) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'x${slice.repeat}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.white70),
                                      onPressed: () => _deleteSlice(index),
                                      tooltip: 'Xóa',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<WheelSlice> slices;

  WheelPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final sweepAngle = 2 * math.pi / slices.length;

    for (int i = 0; i < slices.length; i++) {
      final paint = Paint()
        ..color = slices[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw text
      final angle = -math.pi / 2 + i * sweepAngle + sweepAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(angle);
      final textY = center.dy + textRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: slices[i].name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.15, centerPaint);

    // Draw "Spin" text
    final spinPainter = TextPainter(
      text: const TextSpan(
        text: 'Spin',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    spinPainter.layout();
    spinPainter.paint(
      canvas,
      Offset(center.dx - spinPainter.width / 2, center.dy - spinPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EditSliceDialog extends StatefulWidget {
  final String initialName;
  final String initialEmoji;

  const _EditSliceDialog({
    required this.initialName,
    this.initialEmoji = '',
  });

  @override
  State<_EditSliceDialog> createState() => _EditSliceDialogState();
}

class _EditSliceDialogState extends State<_EditSliceDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emojiController = TextEditingController(text: widget.initialEmoji);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm phần thưởng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Tên phần thưởng',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emojiController,
            decoration: const InputDecoration(
              labelText: 'Emoji (tùy chọn)',
              border: OutlineInputBorder(),
              hintText: '🎁',
            ),
            maxLength: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'emoji': _emojiController.text.trim(),
              });
            }
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
