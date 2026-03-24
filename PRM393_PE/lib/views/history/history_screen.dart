import 'package:flutter/material.dart';
import 'package:prm393_pe/services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, String>> _history = [];
  String _filterGame = 'Tất cả';
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = _filterGame == 'Tất cả'
        ? await StorageService.getHistory()
        : await StorageService.getHistoryByGame(_filterGame);
    final count = await StorageService.getHistoryCount();
    
    setState(() {
      _history = history;
      _totalCount = count;
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📜 Lịch Sử Trúng Thưởng'),
            Text(
              '$_totalCount kết quả',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
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
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tất cả'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vòng Quay'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Random Số'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Lì Xì'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          
          // History list
          Expanded(
            child: _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 20),
                        Text(
                          _filterGame == 'Tất cả' 
                              ? 'Chưa có lịch sử'
                              : 'Không có kết quả cho $_filterGame',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
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
                            '${item['game']} • ${_formatTime(item['time'] ?? '')}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filterGame == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterGame = label;
        });
        _loadHistory();
      },
      selectedColor: Colors.red.shade700,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          if (diff.inMinutes == 0) {
            return 'Vừa xong';
          }
          return '${diff.inMinutes} phút trước';
        }
        return '${diff.inHours} giờ trước';
      } else if (diff.inDays == 1) {
        return 'Hôm qua';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} ngày trước';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return time;
    }
  }
}
