import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name    = '';
  String _email   = '';
  bool _isLoading = true;

  int _packed   = 0;
  int _delivery = 0;
  int _selesai  = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadOrderStats();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await ApiService.profile();
      if (result['status'] == true) {
        final user = result['user'];
        setState(() {
          _name      = user['name']  ?? '';
          _email     = user['email'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrderStats() async {
    try {
      final result = await ApiService.getOrders();
      if (result['status'] == true) {
        final orders = result['orders'] as List? ?? [];
        setState(() {
          _packed   = orders.where((o) =>
              o['status'] == 'processing' || o['status'] == 'paid').length;
          _delivery = orders.where((o) =>
              o['status'] == 'shipped').length;
          _selesai  = orders.where((o) =>
              o['status'] == 'delivered').length;
        });
      }
    } catch (e) {
      // abaikan
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF12122E),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(color: Colors.white)),
        content: const Text('Apakah kamu yakin ingin keluar?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.logout();
      } catch (e) {
        // tetap logout lokal
      }
      await ApiService.removeToken();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/auth', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.blue))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildMyOrders(),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // -----------------------------------------------------------
  // HEADER
  // -----------------------------------------------------------
  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          children: [
            // Judul + ikon settings
            Row(
              children: [
                const Spacer(),
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings_outlined,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Avatar + nama + email
            Row(
              children: [
                // Avatar
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade500,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: const Icon(Icons.person,
                      color: Colors.white70, size: 36),
                ),
                const SizedBox(width: 16),

                // Nama & email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _name.isNotEmpty ? _name : 'Pengguna VHGH',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // MY ORDERS
  // -----------------------------------------------------------
  Widget _buildMyOrders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/orders'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOrderStat(
                      Icons.inventory_2_outlined, 'Packed', _packed),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _buildOrderStat(
                      Icons.local_shipping_outlined, 'Delivery', _delivery),
                  Container(width: 1, height: 50, color: Colors.white24),
                  _buildOrderStat(
                      Icons.star_border_rounded, 'Rating', _selesai),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStat(IconData icon, String label, int count) {
    return Column(
      children: [
        Text(
          count > 0 ? '$count' : '...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // -----------------------------------------------------------
  // MENU SECTION
  // -----------------------------------------------------------
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildMenuItem(
            icon: Icons.favorite_border,
            label: 'Whishlist',
            onTap: () => Navigator.pushNamed(context, '/wishlist'),
          ),
          const SizedBox(height: 10),

          _buildMenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Pesanan Saya',
            onTap: () => Navigator.pushNamed(context, '/orders'),
          ),
          const SizedBox(height: 10),

          _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            label: 'Contact Us',
            onTap: () {},
          ),
          const SizedBox(height: 10),

          // Logout — warna merah
          GestureDetector(
            onTap: _handleLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.logout,
                        color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward,
                      color: Colors.red, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // BOTTOM NAV BAR
  // -----------------------------------------------------------
  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_rounded,           'label': 'Home',    'route': '/home'},
      {'icon': Icons.search,                 'label': 'Search',  'route': '/search'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart',    'route': '/cart'},
      {'icon': Icons.favorite_border,        'label': 'Wishlist','route': '/wishlist'},
      {'icon': Icons.person_outline,         'label': 'Profile', 'route': ''},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = index == 4;
              return GestureDetector(
                onTap: () {
                  final route = items[index]['route'] as String;
                  if (route.isNotEmpty) {
                    Navigator.pushNamed(context, route);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index]['icon'] as IconData,
                      color: isSelected ? AppColors.blue : Colors.white38,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.blue : Colors.white38,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}