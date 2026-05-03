import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedFilter = 'Semua';
  List<dynamic> _orders  = [];
  bool _isLoading        = true;

  final List<String> _filters = [
    'Semua', 'Diproses', 'Dikirim', 'Selesai', 'Dibatalkan'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getOrders();
      if (result['status'] == true) {
        setState(() {
          _orders    = result['orders'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredOrders {
    if (_selectedFilter == 'Semua') return _orders;
    return _orders.where((o) {
      final status = o['status']?.toString().toLowerCase() ?? '';
      switch (_selectedFilter) {
        case 'Diproses':
          return status == 'pending' || status == 'processing' || status == 'paid';
        case 'Dikirim':
          return status == 'shipped';
        case 'Selesai':
          return status == 'delivered';
        case 'Dibatalkan':
          return status == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  // Pisahkan aktif dan riwayat
  List<dynamic> get _activeOrders => _filteredOrders.where((o) {
    final s = o['status']?.toString().toLowerCase() ?? '';
    return s == 'pending' || s == 'paid' ||
           s == 'processing' || s == 'shipped';
  }).toList();

  List<dynamic> get _historyOrders => _filteredOrders.where((o) {
    final s = o['status']?.toString().toLowerCase() ?? '';
    return s == 'delivered' || s == 'cancelled';
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildAppBar(),
          _buildFilterTabs(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue))
                : _orders.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        color: AppColors.blue,
                        child: _buildOrderList(),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // -----------------------------------------------------------
  // APP BAR
  // -----------------------------------------------------------
  Widget _buildAppBar() {
    return SafeArea(
      child: Container(
        color: AppColors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.chevron_left,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'PESANAN SAYA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // FILTER TABS
  // -----------------------------------------------------------
  Widget _buildFilterTabs() {
    return Container(
      color: const Color(0xFF0D0D2B),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.blue
                      : const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.blue : Colors.white24,
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // EMPTY STATE
  // -----------------------------------------------------------
  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              color: Colors.white24, size: 80),
          SizedBox(height: 16),
          Text('Belum ada pesanan',
              style: TextStyle(color: Colors.white38, fontSize: 16)),
          SizedBox(height: 8),
          Text('Yuk mulai belanja produk VHGH!',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // ORDER LIST
  // -----------------------------------------------------------
  Widget _buildOrderList() {
    final active  = _activeOrders;
    final history = _historyOrders;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section AKTIF
        if (active.isNotEmpty) ...[
          _buildSectionLabel('AKTIF'),
          const SizedBox(height: 10),
          ...active.map((order) => _buildOrderCard(order)),
          const SizedBox(height: 16),
        ],

        // Section RIWAYAT
        if (history.isNotEmpty) ...[
          _buildSectionLabel('RIWAYAT'),
          const SizedBox(height: 10),
          ...history.map((order) => _buildOrderCard(order)),
        ],

        // Kalau filter aktif dan tidak ada hasil
        if (active.isEmpty && history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'Tidak ada pesanan $_selectedFilter',
                style: const TextStyle(
                    color: Colors.white38, fontSize: 14),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  // -----------------------------------------------------------
  // ORDER CARD
  // -----------------------------------------------------------
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final items  = order['items'] as List? ?? [];
    final status = order['status']?.toString() ?? 'pending';
    final kode   = order['kode_order']?.toString() ?? '-';
    final tanggal= order['created_at']?.toString() ?? '-';
    final kurir  = order['kurir']?.toString() ?? '-';
    final total  = double.tryParse(order['total_harga'].toString()) ?? 0;

    return GestureDetector(
      onTap: () {
        // TODO: Navigate ke detail pesanan
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF12122E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            // Header order
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#$kode',
                          style: const TextStyle(
                            color: AppColors.blue,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$tanggal · $kurir',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Items
            ...items.map((item) => _buildOrderItemRow(item, total)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemRow(Map<String, dynamic> item, double total) {
    final name   = item['name']?.toString() ?? '-';
    final ukuran = item['ukuran']?.toString() ?? '-';
    final jumlah = item['jumlah']?.toString() ?? '1';
    final gambar = item['gambar']?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Gambar produk
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: gambar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(gambar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.checkroom,
                            color: Colors.white30,
                            size: 22)),
                  )
                : const Icon(Icons.checkroom,
                    color: Colors.white30, size: 22),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Ukuran $ukuran · x$jumlah',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          // Total harga
          Text(
            'Rp ${_formatPrice(total.toInt())}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // STATUS BADGE
  // -----------------------------------------------------------
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        label = 'Diproses';
        icon  = Icons.circle;
        break;
      case 'paid':
      case 'processing':
        color = Colors.orange;
        label = 'Diproses';
        icon  = Icons.circle;
        break;
      case 'shipped':
        color = AppColors.blue;
        label = 'Dikirim';
        icon  = Icons.circle;
        break;
      case 'delivered':
        color = AppColors.green;
        label = 'Selesai';
        icon  = Icons.circle;
        break;
      case 'cancelled':
        color = Colors.red;
        label = 'Dibatalkan';
        icon  = Icons.circle;
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
        icon  = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 8),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // BOTTOM NAV BAR
  // -----------------------------------------------------------
  Widget _buildBottomNavBar() {
    final items = [
      {'icon': Icons.home_rounded,           'label': 'Home',    'route': '/home'},
      {'icon': Icons.search,                 'label': 'Search',  'route': ''},
      {'icon': Icons.shopping_cart_outlined, 'label': 'Cart',    'route': '/cart'},
      {'icon': Icons.favorite_border,        'label': 'Wishlist','route': ''},
      {'icon': Icons.person_outline,         'label': 'Profile', 'route': '/profile'},
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
              final isSelected = index == 4; // Orders tab aktif
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