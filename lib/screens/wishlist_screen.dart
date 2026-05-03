import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _items    = [];
  bool _isLoading         = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getWishlist();
      if (result['status'] == true) {
        final rawItems = result['items'] as List? ?? [];
        setState(() {
          _items = rawItems.map((item) => Product(
            id:        item['product_id'],
            name:      item['name'],
            harga:     double.parse(item['harga'].toString()),
            kategori:  item['kategori'] ?? '',
            gambar:    item['gambar'],
            deskripsi: item['deskripsi'],
            stok:      item['stok'] ?? 0,
            isWishlisted: true,
          )).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memuat wishlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _removeFromWishlist(Product product) async {
    try {
      final result = await ApiService.toggleWishlist(product.id);
      if (result['status'] == true) {
        setState(() => _items.remove(product));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} dihapus dari wishlist'),
              backgroundColor: AppColors.blue,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      // abaikan error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue))
                : _items.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: _loadWishlist,
                        color: AppColors.blue,
                        child: _buildGrid(),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
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
            const SizedBox(width: 14),

            // Judul
            const Text(
              'Wishlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),

            // Jumlah item
            if (_items.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '${_items.length} produk',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF12122E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.favorite_border,
                color: Colors.white24, size: 48),
          ),
          const SizedBox(height: 20),
          const Text(
            'Wishlist masih kosong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Simpan produk favoritmu di sini!',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/home'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1D4ED8), AppColors.blue],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Mulai Belanja',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // GRID PRODUK
  // -----------------------------------------------------------
  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) =>
          _buildWishlistCard(_items[index]),
    );
  }

  Widget _buildWishlistCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12122E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            Expanded(
              child: Stack(
                children: [
                  // Gambar / placeholder
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    child: product.gambar != null
                        ? Image.network(
                            product.gambar!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),

                  // Tombol hapus wishlist (❤️ merah)
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => _removeFromWishlist(product),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info produk
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rp ${_formatPrice(product.harga.toInt())}',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Tombol tambah ke cart
                      GestureDetector(
                        onTap: () async {
                          final result = await ApiService.addToCart(
                              product.id, 'M', 1);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    result['message'] ??
                                        'Ditambahkan ke keranjang'),
                                backgroundColor:
                                    result['status'] == true
                                        ? AppColors.blue
                                        : Colors.red,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1a2a6c), Color(0xFF2563EB)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.checkroom, color: Colors.white30, size: 50),
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
      {'icon': Icons.favorite,               'label': 'Wishlist','route': ''},
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
              final isSelected = index == 3; // Wishlist aktif
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
                      color: isSelected ? Colors.red : Colors.white38,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white38,
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