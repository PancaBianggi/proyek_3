import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

// =============================================================
// MODEL PRODUK — dari API Laravel
// =============================================================
class Product {
  final int id;
  final String name;
  final double harga;
  final String kategori;
  final String? gambar;
  final String? deskripsi;
  final int stok;
  bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.harga,
    required this.kategori,
    this.gambar,
    this.deskripsi,
    required this.stok,
    this.isWishlisted = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      harga: double.parse(json['harga'].toString()),
      kategori: json['kategori'],
      gambar: json['gambar'],
      deskripsi: json['deskripsi'],
      stok: json['stok'] ?? 0,
    );
  }
}

// =============================================================
// HOME SCREEN
// =============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  String _selectedCategory = 'Semua';
  bool _isLoading = true;
  List<Product> _products = [];

  final List<String> _categories = ['Semua', 'T-Shirt', 'Jacket', 'Pants'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProducts();
      setState(() {
        _products = data.map((p) => Product.fromJson(p)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Semua') return _products;
    return _products.where((p) => p.kategori == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                color: AppColors.blue,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildHeroBanner(),
                      const SizedBox(height: 20),
                      _buildCategoryFilter(),
                      const SizedBox(height: 16),
                      _buildProductGrid(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // -----------------------------------------------------------
  // APP BAR
  // -----------------------------------------------------------
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                  children: [
                    TextSpan(
                      text: 'VH',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'G',
                      style: TextStyle(color: AppColors.blue),
                    ),
                    TextSpan(
                      text: 'H',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Text(
                'Selamat Datang',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              _iconButton(Icons.chat_bubble_outline, () {
                Navigator.pushNamed(context, '/chatbot');
              }),
              const SizedBox(width: 8),
              _iconButton(Icons.search, () {}),
              const SizedBox(width: 8),
              _iconButton(Icons.notifications_none, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF12122E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // -----------------------------------------------------------
  // HERO BANNER
  // -----------------------------------------------------------
  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a4e), Color(0xFF0d1b4b)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VHGH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const Text(
              '2026',
              style: TextStyle(
                color: AppColors.blue,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Style tanpa batas, ekspresi tanpa akhir',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat Koleksi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // CATEGORY FILTER
  // -----------------------------------------------------------
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kategori',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
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
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Produk Pilihan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // PRODUCT GRID
  // -----------------------------------------------------------
  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppColors.blue),
        ),
      );
    }

    final products = _filteredProducts;

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Tidak ada produk',
            style: TextStyle(color: Colors.white38),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => _buildProductCard(products[index]),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: product.gambar != null
                        ? Image.network(
                            product.gambar!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                  // Tombol wishlist
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await ApiService.toggleWishlist(
                          product.id,
                        );
                        if (result['status'] == true) {
                          setState(() {
                            product.isWishlisted = result['wishlisted'];
                          });
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          product.isWishlisted
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isWishlisted
                              ? Colors.red
                              : Colors.white,
                          size: 16,
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
              child: Row(
                children: [
                  Expanded(
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
                        const SizedBox(height: 3),
                        Text(
                          'Rp ${_formatPrice(product.harga.toInt())}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol tambah cart
                  GestureDetector(
                    onTap: () async {
                      final result = await ApiService.addToCart(
                        product.id,
                        'M', // default ukuran, nanti user pilih di halaman detail
                        1,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Ditambahkan ke keranjang',
                            ),
                            backgroundColor: result['status'] == true
                                ? AppColors.blue
                                : Colors.red,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
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
              final isSelected = _selectedNavIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedNavIndex = index);
                  switch (index) {
                    case 1:
                      // TODO: Search screen
                      break;
                    case 2:
                      Navigator.pushNamed(context, '/cart');
                      break;
                    case 3:
                      Navigator.pushNamed(context, '/wishlist');
                      break;
                    case 4:
                      Navigator.pushNamed(context, '/profile');
                      break;
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
    if (price >= 1000) return '${price ~/ 1000}k';
    return price.toString();
  }
}
