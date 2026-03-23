import 'package:flutter/material.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'package:prm393_pe/data/implementations/repositories/red_envelope_repository_impl.dart';
import 'package:prm393_pe/viewmodels/red_envelope_viewmodel.dart';

class RedEnvelopeSettingsScreen extends StatefulWidget {
  const RedEnvelopeSettingsScreen({super.key});

  @override
  State<RedEnvelopeSettingsScreen> createState() => _RedEnvelopeSettingsScreenState();
}

class _RedEnvelopeSettingsScreenState extends State<RedEnvelopeSettingsScreen> {
  late RedEnvelopeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    final repository = RedEnvelopeRepositoryImpl(AppDatabase.instance);
    _viewModel = RedEnvelopeViewModel(repository);
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadPrizes();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  Future<void> _addPrize() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _PrizeDialog(),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _viewModel.addPrize(result.trim());
    }
  }

  Future<void> _editPrize(int id, String currentName) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _PrizeDialog(initialValue: currentName),
    );

    if (result != null && result.trim().isNotEmpty) {
      await _viewModel.updatePrize(id, result.trim());
    }
  }

  Future<void> _deletePrize(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "$name"?'),
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
      await _viewModel.deletePrize(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt phần thưởng'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Just pop back, data is already saved in database
              Navigator.pop(context, true);
            },
            tooltip: 'Xong',
          ),
        ],
      ),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewModel.prizes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.card_giftcard, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 20),
                      Text(
                        'Chưa có phần thưởng',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nhấn nút + để thêm',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _viewModel.prizes.length,
                  onReorder: _viewModel.reorderPrizes,
                  itemBuilder: (context, index) {
                    final prize = _viewModel.prizes[index];
                    return Card(
                      key: ValueKey(prize.id),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.drag_handle, color: Colors.grey),
                        title: Text(
                          prize.prizeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editPrize(prize.id!, prize.prizeName),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePrize(prize.id!, prize.prizeName),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPrize,
        backgroundColor: Colors.red.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _PrizeDialog extends StatefulWidget {
  final String? initialValue;

  const _PrizeDialog({this.initialValue});

  @override
  State<_PrizeDialog> createState() => _PrizeDialogState();
}

class _PrizeDialogState extends State<_PrizeDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialValue == null ? 'Thêm phần thưởng' : 'Sửa phần thưởng'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Tên phần thưởng',
          border: OutlineInputBorder(),
          hintText: 'VD: 100.000đ',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
