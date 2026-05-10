import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

// =============================================================
// MODEL CART ITEM
// =============================================================
class CartItemModel {
  final int    id;
  final int    productId;
  final String name;
  final double harga;
  final String? gambar;
  final String ukuran;
  int          jumlah;
  double       subtotal;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.harga,
    this.gambar,
    required this.ukuran,
    required this.jumlah,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id:       json['id'],
      productId:json['product_id'],
      name:     json['name'],
      harga:    double.parse(json['harga'].toString()),
      gambar:   json['gambar'],
      ukuran:   json['ukuran'] ?? 'M',
      jumlah:   json['jumlah'],
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

// =============================================================
// CART SCREEN
// =============================================================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItemModel> _items   = [];
  bool   _isLoading            = true;
  double _total                = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getCart();
      print('CART RESPONSE: $result'); // tambah ini
      if (result['status'] == true) {
        setState(() {
          _items = (result['items'] as List)
              .map((i) => CartItemModel.fromJson(i))
              .toList();
          _total = double.parse(result['total'].toString());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat keranjang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeItem(CartItemModel item) async {
    try {
      final result = await ApiService.removeFromCart(item.id);
      if (result['status'] == true) {
        setState(() {
          _items.remove(item);
          _recalcTotal();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item dihapus dari keranjang'),
              backgroundColor: AppColors.blue,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // ignore error
    }
  }

  void _recalcTotal() {
    _total = _items.fold(0, (sum, i) => sum + i.subtotal);
  }

  void _goToCheckout() {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang masih kosong!')),
      );
      return;
    }
    Navigator.pushNamed(context, '/checkout');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue))
                : _items.isEmpty
                    ? _buildEmpty()
                    : _buildCartList(),
          ),
          if (!_isLoading && _items.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // APP BAR
  // -----------------------------------------------------------
  Widget _buildAppBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tombol kembali
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 24),
              ),
            ),

            const Text(
              'Keranjang',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),

            // Tombol opsi
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_horiz,
                  color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // EMPTY STATE
  // -----------------------------------------------------------
  Widget _buildEmpty() {
    return Column(
      children: [
        _buildAppBar(),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    color: Colors.white24, size: 80),
                SizedBox(height: 16),
                Text('Keranjang masih kosong',
                    style: TextStyle(color: Colors.white38, fontSize: 16)),
                SizedBox(height: 8),
                Text('Yuk tambahkan produk favoritmu!',
                    style: TextStyle(color: Colors.white24, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // CART LIST
  // -----------------------------------------------------------
  Widget _buildCartList() {
    return RefreshIndicator(
      onRefresh: _loadCart,
      color: AppColors.blue,
      child: CustomScrollView(
        slivers: [
          // App bar
          SliverToBoxAdapter(child: _buildAppBar()),

          // List item keranjang
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCartItem(_items[index]),
              childCount: _items.length,
            ),
          ),

          // Ringkasan total
          SliverToBoxAdapter(child: _buildSummary()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // ITEM KERANJANG
  // -----------------------------------------------------------
  Widget _buildCartItem(CartItemModel item) {
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      onDismissed: (_) => _removeItem(item),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF12122E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 75, height: 75,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B5EFC), Color(0xFF8B9FFF)],
                  ),
                ),
                child: item.gambar != null
                    ? Image.network(item.gambar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.checkroom,
                            color: Colors.white30,
                            size: 35))
                    : const Icon(Icons.checkroom,
                        color: Colors.white30, size: 35),
              ),
            ),
            const SizedBox(width: 14),

            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size : ${item.ukuran}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rp ${_formatPrice(item.subtotal.toInt())}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Counter jumlah
            Column(
              children: [
                // Tombol hapus
                GestureDetector(
                  onTap: () => _removeItem(item),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white38, size: 18),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Tombol kurang
                    GestureDetector(
                      onTap: () {
                        if (item.jumlah > 1) {
                          setState(() {
                            item.jumlah--;
                            item.subtotal = item.harga * item.jumlah;
                            _recalcTotal();
                          });
                        } else {
                          _removeItem(item);
                        }
                      },
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1a1a3e),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.remove,
                            color: Colors.white, size: 14),
                      ),
                    ),

                    // Jumlah
                    Container(
                      width: 32,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.jumlah}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Tombol tambah
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          item.jumlah++;
                          item.subtotal = item.harga * item.jumlah;
                          _recalcTotal();
                        });
                      },
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // RINGKASAN BELANJA
  // -----------------------------------------------------------
  Widget _buildSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Belanja',
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total (${_items.length} produk)',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 13)),
              Text(
                'Rp ${_formatPrice(_total.toInt())}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(
                'Rp ${_formatPrice(_total.toInt())}',
                style: const TextStyle(
                    color: AppColors.blue,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
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
        left: 20, right: 20, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Total harga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12)),
                Text(
                  'Rp ${_formatPrice(_total.toInt())}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Tombol checkout
          GestureDetector(
            onTap: _goToCheckout,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), AppColors.blue],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
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