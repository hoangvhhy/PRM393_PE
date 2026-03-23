import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:prm393_pe/services/storage_service.dart';

class LuckyNumberScreen extends StatefulWidget {
  const LuckyNumberScreen({super.key});

  @override
  State<LuckyNumberScreen> createState() => _LuckyNumberScreenState();
}

class _LuckyNumberScreenState extends State<LuckyNumberScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  
  bool _isRolling = false;
  int _currentNumber = 0;
  int? _winningNumber;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _startRolling() async {
    final min = int.tryParse(_minController.text) ?? 1;
    final max = int.tryParse(_maxController.text) ?? 100;

    if (min >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số min phải nhỏ hơn số max!')),
      );
      return;
    }

    setState(() {
      _isRolling = true;
      _winningNumber = null;
    });

    final random = Random();
    final winner = min + random.nextInt(max - min + 1);

    // Rolling animation
    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(milliseconds: 50 + i * 3));
      if (mounted) {
        setState(() {
          _currentNumber = min + random.nextInt(max - min + 1);
        });
      }
    }

    // Final number
    setState(() {
      _currentNumber = winner;
      _winningNumber = winner;
      _isRolling = false;
    });

    StorageService.saveWinner('Random Số', winner.toString());
    
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _showWinnerDialog(winner);
  }

  void _showWinnerDialog(int number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.amber.shade50,
        title: const Text(
          '🎊 SỐ MAY MẮN 🎊',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎰 Random Số May Mắn'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade700, Colors.purple.shade300],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Number Display
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: _winningNumber != null
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(_glowController.value),
                                  blurRadius: 40,
                                  spreadRadius: 20,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          _currentNumber.toString(),
                          style: TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: _winningNumber != null
                                ? Colors.red.shade700
                                : Colors.purple.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 50),
                
                // Range Input
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Chọn khoảng số',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _minController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Từ',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('→', style: TextStyle(fontSize: 24)),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _maxController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Đến',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Roll Button
                ElevatedButton(
                  onPressed: _isRolling ? null : _startRolling,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.purple.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_isRolling ? '🎲 Đang Quay...' : '🎲 QUAY SỐ!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
