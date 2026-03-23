import 'package:flutter/material.dart';
import 'package:prm393_pe/views/history/history_screen.dart';
import 'package:prm393_pe/views/lucky_number//lucky_number_screen.dart';
import 'package:prm393_pe/views/red_envelope/red_envelope_screen.dart';
import 'package:prm393_pe/views/wheel/wheel_library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade700,
              Colors.red.shade400,
              Colors.orange.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              const Text(
                '🎊 QUAY SỐ MAY MẮN 🎊',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Chúc Mừng Năm Mới',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.yellow,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              
              // Game Mode Cards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGameCard(
                        context,
                        icon: '🎡',
                        title: 'Vòng Quay May Mắn',
                        subtitle: 'Quay và nhận quà',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WheelLibraryScreen()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGameCard(
                        context,
                        icon: '🎰',
                        title: 'Random Số May Mắn',
                        subtitle: 'Quay số trúng thưởng',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LuckyNumberScreen()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildGameCard(
                        context,
                        icon: '🧧',
                        title: 'Lì Xì May Mắn',
                        subtitle: 'Chọn bao lì xì của bạn',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RedEnvelopeScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // History Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                  icon: const Icon(Icons.history, color: Colors.white),
                  label: const Text(
                    'Lịch Sử Trúng Thưởng',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD32F2F),
            ),
          ],
        ),
      ),
    );
  }
}
