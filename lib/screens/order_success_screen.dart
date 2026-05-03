import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  String _kodeOrder = '';
  double _total     = 0;

  // Status tracking dummy (nanti dari API)
  final List<Map<String, dynamic>> _statusList = [
    {
      'icon' : Icons.check_circle,
      'label': 'Pesanan Diterima',
      'sub'  : '23 Feb 2026 · 13:09',
      'done' : true,
    },
    {
      'icon' : Icons.bolt,
      'label': 'Sedang Diproses',
      'sub'  : 'Estimasi selesai hari ini',
      'done' : true,
    },
    {
      'icon' : Icons.local_shipping_outlined,
      'label': 'Dikirim ke Kurir',
      'sub'  : 'Menunggu...',
      'done' : false,
    },
    {
      'icon' : Icons.directions_run,
      'label': 'Dalam Perjalanan',
      'sub'  : 'Menunggu...',
      'done' : false,
    },
    {
      'icon' : Icons.home_outlined,
      'label': 'Pesanan Tiba',
      'sub'  : 'Menunggu...',
      'done' : false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ambil arguments dari navigator
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map) {
      setState(() {
        _kodeOrder = args['kode_order']?.toString() ?? '';
        _total     = double.tryParse(args['total'].toString()) ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyKodeOrder() {
    Clipboard.setData(ClipboardData(text: _kodeOrder));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kode order disalin!'),
        backgroundColor: AppColors.blue,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Bagian atas dengan gradient
                  _buildTopSection(),
                  const SizedBox(height: 24),

                  // Status pesanan
                  _buildStatusSection(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // BAGIAN ATAS (icon centang + judul + kode order)
  // -----------------------------------------------------------
  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 40,
        bottom: 32,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D0D2B), Color(0xFF0A0A1F)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // Lingkaran centang hijau
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.green,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Judul
            const Text(
              'PESANAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const Text(
              'BERHASIL!',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),

            // Subjudul
            const Text(
              'Terima kasih! Pesananmu sedang diproses\ndan akan segera dikirimkan 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Kode Order
            GestureDetector(
              onTap: _copyKodeOrder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ORDER ID  ',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1),
                    ),
                    Text(
                      '#${_kodeOrder.isNotEmpty ? _kodeOrder : 'VHGH-XXXXXXXX'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy,
                        color: Colors.white54, size: 16),
                  ],
                ),
              ),
            ),

            // Total (jika ada)
            if (_total > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Total: Rp ${_formatPrice(_total.toInt())}',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // STATUS PESANAN
  // -----------------------------------------------------------
  Widget _buildStatusSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul section
          Row(
            children: [
              Container(
                width: 4, height: 18,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'STATUS PESANAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // List status
          ...List.generate(_statusList.length, (index) {
            final item    = _statusList[index];
            final isDone  = item['done'] as bool;
            final isLast  = index == _statusList.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon + garis vertikal
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.green.withOpacity(0.2)
                            : const Color(0xFF12122E),
                        border: Border.all(
                          color: isDone
                              ? AppColors.green
                              : Colors.white24,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 18,
                        color: isDone
                            ? AppColors.green
                            : Colors.white38,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: isDone
                            ? AppColors.green.withOpacity(0.4)
                            : Colors.white12,
                      ),
                  ],
                ),
                const SizedBox(width: 14),

                // Label + sub
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            color: isDone
                                ? Colors.white
                                : Colors.white38,
                            fontSize: 14,
                            fontWeight: isDone
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['sub'] as String,
                          style: TextStyle(
                            color: isDone
                                ? Colors.white54
                                : Colors.white24,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // BOTTOM BAR
  // -----------------------------------------------------------
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Tombol Belanja Lagi
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Center(
                  child: Text(
                    'Belanja Lagi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Lihat Pesanan
          Expanded(
            child: GestureDetector(
              onTap: () {
                // TODO: navigate ke halaman riwayat pesanan
                Navigator.pushNamed(context, '/orders');
              },
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), AppColors.blue],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Lihat Pesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // HELPER
  // -----------------------------------------------------------
  String _formatPrice(int price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}jt';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}k';
    }
    return price.toString();
  }
}