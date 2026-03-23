import 'package:flutter/material.dart';
import 'package:prm393_pe/services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await StorageService.getHistory();
    setState(() {
      _history = history;
    });
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa toàn bộ lịch sử?'),
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
      await StorageService.clearHistory();
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 Lịch Sử Trúng Thưởng'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: _history.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Chưa có lịch sử',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[_history.length - 1 - index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade700,
                      child: Text(
                        _getGameIcon(item['game'] ?? ''),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    title: Text(
                      item['winner'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      '${item['game']} • ${item['time']}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _getGameIcon(String game) {
    switch (game) {
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
