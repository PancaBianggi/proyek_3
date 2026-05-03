import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'home_screen.dart'; // import model Product

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isLoading = false;
  String _selectedSize = 'M';
  int _quantity = 1;

  final List<String> _sizes = ['S', 'M', 'L', 'XL', 'XXL'];

  final double _rating = 4.9;

  int get _totalStock => widget.product.stok;

  void _decreaseQty() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _increaseQty() {
    if (_quantity < _totalStock) setState(() => _quantity++);
  }

  Future<void> _addToCart() async {
    try {
      final result = await ApiService.addToCart(
        widget.product.id,
        _selectedSize,
        _quantity,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Ditambahkan ke keranjang'),
            backgroundColor: result['status'] == true
                ? AppColors.blue
                : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menambahkan ke keranjang'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _buyNow() async {
    setState(() => _isLoading = true);

    try {
      // Tambah ke cart dulu
      final cartResult = await ApiService.addToCart(
        widget.product.id,
        _selectedSize,
        _quantity,
      );

      if (cartResult['status'] == true) {
        // Langsung ke checkout
        if (mounted) {
          Navigator.pushNamed(context, '/checkout');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                cartResult['message'] ?? 'Gagal menambahkan produk',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat terhubung ke server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitlePrice(),
                        const SizedBox(height: 14),
                        _buildRating(),
                        const SizedBox(height: 20),
                        _buildSizeSelector(),
                        const SizedBox(height: 20),
                        _buildDescription(),
                        const SizedBox(height: 20),
                        _buildQuantitySelector(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // GAMBAR + APP BAR
  // -----------------------------------------------------------
  Widget _buildImageSection() {
    return Stack(
      children: [
        // Area gambar
        Container(
          width: double.infinity,
          height: 320,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4B5EFC), Color(0xFF8B9FFF)],
            ),
          ),
          child: widget.product.gambar != null
              ? Image.network(
                  widget.product.gambar!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.checkroom,
                      color: Colors.white30,
                      size: 120,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.checkroom,
                    color: Colors.white30,
                    size: 120,
                  ),
                ),
        ),

        // App bar overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol kembali
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Judul
                const Text(
                  'Detail Produk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Tombol opsi
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // NAMA + HARGA
  // -----------------------------------------------------------
  Widget _buildTitlePrice() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            widget.product.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'Rp ${_formatPrice(widget.product.harga.toInt())}',
          style: const TextStyle(
            color: AppColors.blue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // RATING
  // -----------------------------------------------------------
  Widget _buildRating() {
    return Row(
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < _rating.floor() ? Icons.star : Icons.star_half,
            color: Colors.amber,
            size: 18,
          );
        }),
        const SizedBox(width: 6),
        Text(
          _rating.toString(),
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // PILIH UKURAN
  // -----------------------------------------------------------
  Widget _buildSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Ukuran',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _sizes.map((size) {
            final isSelected = _selectedSize == size;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue : const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.blue : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
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
      ],
    );
  }

  // -----------------------------------------------------------
  // DESKRIPSI
  // -----------------------------------------------------------
  Widget _buildDescription() {
    final desc =
        widget.product.deskripsi ?? 'Produk fashion premium dari brand VHGH.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // PILIH JUMLAH
  // -----------------------------------------------------------
  Widget _buildQuantitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jumlah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Stok: $_totalStock tersedia',
          style: const TextStyle(color: AppColors.blue, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Tombol kurang
            GestureDetector(
              onTap: _decreaseQty,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.remove, color: Colors.white, size: 18),
              ),
            ),

            // Angka jumlah
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text(
                '$_quantity',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Tombol tambah
            GestureDetector(
              onTap: _increaseQty,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // BOTTOM BAR
  // -----------------------------------------------------------
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Tombol keranjang
          GestureDetector(
            onTap: _addToCart,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF12122E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Beli Sekarang
          // Tombol Beli Sekarang
          Expanded(
            child: GestureDetector(
              onTap: _isLoading ? null : _buyNow,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? const LinearGradient(
                          colors: [Color(0xFF1a1a4e), Color(0xFF1a1a4e)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF1D4ED8), AppColors.blue],
                        ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Beli Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
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
    if (price >= 1000) return '${price ~/ 1000}k';
    return price.toString();
  }
}
