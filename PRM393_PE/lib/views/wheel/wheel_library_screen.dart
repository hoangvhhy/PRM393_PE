import 'package:flutter/material.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'package:prm393_pe/views/wheel/lucky_wheel_screen.dart';
import 'dart:math' as math;

class WheelLibraryScreen extends StatefulWidget {
  const WheelLibraryScreen({super.key});

  @override
  State<WheelLibraryScreen> createState() => _WheelLibraryScreenState();
}

class _WheelLibraryScreenState extends State<WheelLibraryScreen> {
  List<Map<String, dynamic>> _savedWheels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedWheels();
  }

  Future<void> _loadSavedWheels() async {
    setState(() => _isLoading = true);
    final wheels = await AppDatabase.instance.getSavedWheels();
    setState(() {
      _savedWheels = wheels;
      _isLoading = false;
    });
  }

  Future<void> _createNewWheel() async {
    final title = await _showTitleDialog();
    if (title != null && title.trim().isNotEmpty) {
      final wheelId = await AppDatabase.instance.insertSavedWheel(title.trim(), 4.0);
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LuckyWheelScreen(wheelId: wheelId, wheelTitle: title.trim()),
          ),
        ).then((_) => _loadSavedWheels());
      }
    }
  }

  Future<String?> _showTitleDialog({String? initialTitle}) async {
    final controller = TextEditingController(text: initialTitle);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(initialTitle == null ? 'Tạo vòng quay mới' : 'Đổi tên vòng quay'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Tên vòng quay',
            border: OutlineInputBorder(),
            hintText: 'VD: Quay số may mắn',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _renameWheel(int wheelId, String currentTitle) async {
    final newTitle = await _showTitleDialog(initialTitle: currentTitle);
    if (newTitle != null && newTitle.trim().isNotEmpty) {
      final wheel = await AppDatabase.instance.getSavedWheel(wheelId);
      if (wheel != null) {
        await AppDatabase.instance.updateSavedWheel(
          wheelId,
          newTitle.trim(),
          (wheel['spin_time'] as num).toDouble(),
        );
        _loadSavedWheels();
      }
    }
  }

  Future<void> _deleteWheel(int wheelId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa vòng quay "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AppDatabase.instance.deleteSavedWheel(wheelId);
      _loadSavedWheels();
    }
  }

  void _openWheel(int wheelId, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LuckyWheelScreen(wheelId: wheelId, wheelTitle: title),
      ),
    ).then((_) => _loadSavedWheels());
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
      return '${(diff.inDays / 365).floor()} years ago';
    } catch (e) {
      return 'Never';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spin The Wheel',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Random Picker',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bolt, color: Colors.amber),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedWheels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.album, size: 100, color: Colors.grey.shade600),
                      const SizedBox(height: 20),
                      Text(
                        'Chưa có vòng quay nào',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút + để tạo mới',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedWheels.length,
                  itemBuilder: (context, index) {
                    final wheel = _savedWheels[index];
                    return _buildWheelCard(wheel);
                  },
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'star',
            onPressed: () {},
            backgroundColor: Colors.purple,
            child: const Icon(Icons.star, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: _createNewWheel,
            backgroundColor: Colors.red.shade700,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWheelCard(Map<String, dynamic> wheel) {
    final wheelId = wheel['id'] as int;
    final title = wheel['title'] as String;
    final spinCount = wheel['spin_count'] as int;
    final lastUsed = wheel['last_used'] as String?;

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openWheel(wheelId, title),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Wheel Preview
              FutureBuilder<List<Map<String, dynamic>>>(
                future: AppDatabase.instance.getWheelSlices(wheelId),
                builder: (context, snapshot) {
                  final slices = snapshot.data ?? [];
                  return Container(
                    width: 120,
                    height: 120,
                    child: slices.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Empty',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          )
                        : CustomPaint(
                            painter: _MiniWheelPainter(slices),
                          ),
                  );
                },
              ),
              const SizedBox(width: 16),
              
              // Wheel Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Spins: $spinCount',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      'Used: ${_formatDate(lastUsed)}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                color: const Color(0xFF2C2C2C),
                onSelected: (value) {
                  if (value == 'rename') {
                    _renameWheel(wheelId, title);
                  } else if (value == 'delete') {
                    _deleteWheel(wheelId, title);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Share', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Rename', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Settings', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniWheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> slices;

  _MiniWheelPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final sweepAngle = 2 * math.pi / slices.length;

    for (int i = 0; i < slices.length; i++) {
      final colorValue = slices[i]['color'] as int;
      final paint = Paint()
        ..color = Color(colorValue)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2 + i * sweepAngle,
        sweepAngle,
        true,
        paint,
      );
    }

    // Draw center circle with "Spin" button
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.2, centerPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Spin',
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
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
