import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:prm393_pe/services/storage_service.dart';
import 'package:prm393_pe/data/implementations/local/app_database.dart';
import 'package:prm393_pe/data/implementations/repositories/red_envelope_repository_impl.dart';
import 'package:prm393_pe/viewmodels/red_envelope_viewmodel.dart';
import 'package:prm393_pe/views/red_envelope/red_envelope_settings_screen.dart';

class RedEnvelopeScreen extends StatefulWidget {
  const RedEnvelopeScreen({super.key});

  @override
  State<RedEnvelopeScreen> createState() => _RedEnvelopeScreenState();
}

class _RedEnvelopeScreenState extends State<RedEnvelopeScreen>
    with TickerProviderStateMixin {
  late RedEnvelopeViewModel _viewModel;
  List<String> _prizes = [];
  List<AnimationController> _shakeControllers = [];
  late ConfettiController _confettiController;
  String? _selectedPrize;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    final repository = RedEnvelopeRepositoryImpl(AppDatabase.instance);
    _viewModel = RedEnvelopeViewModel(repository);
    _viewModel.addListener(_onViewModelChanged);
    _loadPrizes();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {
        if (_viewModel.prizes.isNotEmpty) {
          _prizes = _viewModel.prizes.map((p) => p.prizeName).toList();
        } else {
          // Fallback to default prizes if database is empty
          _prizes = [
            '100.000đ', '200.000đ', '500.000đ', '1.000.000đ',
            'iPhone 15', 'AirPods', 'Sổ đỏ', '1 căn Vinhome',
            'Biệt thự', 'Thẻ cào 100k'
          ];
        }
        _shufflePrizes();
        _initShakeAnimations();
      });
    }
  }

  Future<void> _loadPrizes() async {
    try {
      await _viewModel.loadPrizes();
      // If still empty after loading, trigger the fallback
      if (_viewModel.prizes.isEmpty && mounted) {
        _onViewModelChanged();
      }
    } catch (e) {
      print('Error loading prizes: $e');
      // Use default prizes on error
      if (mounted) {
        setState(() {
          _prizes = [
            '100.000đ', '200.000đ', '500.000đ', '1.000.000đ',
            'iPhone 15', 'AirPods', 'Sổ đỏ', '1 căn Vinhome',
            'Biệt thự', 'Thẻ cào 100k'
          ];
          _shufflePrizes();
          _initShakeAnimations();
        });
      }
    }
  }

  void _shufflePrizes() {
    if (_prizes.isNotEmpty) {
      _prizes.shuffle();
    }
  }

  void _initShakeAnimations() {
    // Dispose old controllers first
    for (var controller in _shakeControllers) {
      controller.dispose();
    }
    _shakeControllers.clear();
    
    // Create new controllers
    for (int i = 0; i < _prizes.length; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800 + Random().nextInt(400)),
      )..repeat(reverse: true);
      _shakeControllers.add(controller);
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    for (var controller in _shakeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _openSettings() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RedEnvelopeSettingsScreen()),
    );

    if (result == true) {
      await _loadPrizes();
      setState(() {
        _selectedIndex = null;
        _selectedPrize = null;
      });
    }
  }

  void _openEnvelope(int index) {
    if (_selectedIndex != null) return;

    setState(() {
      _selectedIndex = index;
      _selectedPrize = _prizes[index];
    });

    // Stop all animations
    for (var controller in _shakeControllers) {
      controller.stop();
    }

    // Start confetti
    _confettiController.play();

    StorageService.saveWinner('Lì Xì', _selectedPrize!);

    Future.delayed(const Duration(milliseconds: 500), () {
      _showPrizeDialog();
    });
  }

  void _showPrizeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.orange.shade400],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 60),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chúc Mừng!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Bạn nhận được:',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _selectedPrize ?? '',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedIndex = null;
                            _selectedPrize = null;
                            _shufflePrizes();
                          });
                          _initShakeAnimations();
                        },
                        child: const Text(
                          'Chơi Lại',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Về Trang Chủ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Confetti on top of dialog
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.3,
              colors: const [
                Colors.red,
                Colors.yellow,
                Colors.orange,
                Colors.pink,
                Colors.amber,
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 0,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.red,
                Colors.yellow,
                Colors.orange,
                Colors.pink,
                Colors.amber,
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi,
              maxBlastForce: 10,
              minBlastForce: 5,
              emissionFrequency: 0.05,
              numberOfParticles: 30,
              gravity: 0.1,
              colors: const [
                Colors.red,
                Colors.yellow,
                Colors.orange,
                Colors.pink,
                Colors.amber,
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧧 Lì Xì May Mắn'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
            tooltip: 'Cài đặt phần thưởng',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade400, Colors.orange.shade200],
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Chọn 1 bao lì xì bất kỳ!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: _prizes.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: _prizes.length,
                      itemBuilder: (context, index) {
                        return _buildEnvelope(index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvelope(int index) {
    final isSelected = _selectedIndex == index;
    final isOtherSelected = _selectedIndex != null && !isSelected;

    if (index >= _shakeControllers.length) {
      return const SizedBox();
    }

    return AnimatedBuilder(
      animation: _shakeControllers[index],
      builder: (context, child) {
        final shake = _selectedIndex == null
            ? sin(_shakeControllers[index].value * 2 * pi) * 5
            : 0.0;

        return Transform.translate(
          offset: Offset(shake, 0),
          child: GestureDetector(
            onTap: () => _openEnvelope(index),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: isOtherSelected ? 0.3 : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.2 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.yellow.shade700,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isSelected ? '🎁' : '🧧',
                        style: const TextStyle(fontSize: 60),
                      ),
                      if (isSelected && _selectedPrize != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _selectedPrize!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
