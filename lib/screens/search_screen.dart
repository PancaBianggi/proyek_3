import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Product> _results  = [];
  List<Product> _allProducts = [];
  bool _isLoading         = false;
  bool _hasSearched       = false;
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua', 'T-Shirt', 'Jacket', 'Pants'
  ];

  // Riwayat pencarian (local, nanti bisa disimpan ke SharedPreferences)
  final List<String> _recentSearches = [
    'Hoodie', 'T-Shirt', 'Cargo Pants'
  ];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    try {
      final data = await ApiService.getProducts();
      setState(() {
        _allProducts = data.map((p) => Product.fromJson(p)).toList();
      });
    } catch (e) {
      // abaikan
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results    = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Tambah ke riwayat
      if (!_recentSearches.contains(query.trim())) {
        setState(() {
          _recentSearches.insert(0, query.trim());
          if (_recentSearches.length > 5) _recentSearches.removeLast();
        });
      }

      final data = await ApiService.getProducts(search: query.trim());
      setState(() {
        _results     = data.map((p) => Product.fromJson(p)).toList();
        _hasSearched = true;
        _isLoading   = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterByCategory(String category) {
    setState(() => _selectedCategory = category);
  }

  List<Product> get _filteredResults {
    if (_selectedCategory == 'Semua') return _results;
    return _results.where((p) => p.kategori == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildSearchBar(),
          if (_hasSearched) _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue))
                : !_hasSearched
                    ? _buildDefaultView()
                    : _filteredResults.isEmpty
                        ? _buildEmpty()
                        : _buildResults(),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // SEARCH BAR
  // -----------------------------------------------------------
  Widget _buildSearchBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            // Tombol kembali
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chevron_left,
                    color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),

            // Search input
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search,
                        color: Colors.white38, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Cari produk VHGH...',
                          hintStyle: TextStyle(
                              color: Colors.white38, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 0),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        onChanged: (val) {
                          if (val.isEmpty) {
                            setState(() {
                              _results     = [];
                              _hasSearched = false;
                            });
                          }
                        },
                      ),
                    ),
                    // Tombol clear
                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _results     = [];
                            _hasSearched = false;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.close,
                              color: Colors.white38, size: 18),
                        ),
                      ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => _filterByCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
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
                    fontSize: 12,
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
  // DEFAULT VIEW (sebelum search)
  // -----------------------------------------------------------
  Widget _buildDefaultView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Riwayat pencarian
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pencarian Terakhir',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () =>
                      setState(() => _recentSearches.clear()),
                  child: const Text('Hapus Semua',
                      style: TextStyle(
                          color: AppColors.blue, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = s;
                    _search(s);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12122E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history,
                            color: Colors.white38, size: 14),
                        const SizedBox(width: 6),
                        Text(s,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Produk populer
          const Text('Produk Populer',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (_allProducts.isEmpty)
            const Center(
              child: CircularProgressIndicator(color: AppColors.blue),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _allProducts.take(4).length,
              itemBuilder: (context, index) =>
                  _buildProductCard(_allProducts[index]),
            ),
        ],
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
          const Icon(Icons.search_off,
              color: Colors.white24, size: 70),
          const SizedBox(height: 16),
          Text(
            'Produk "${_searchController.text}" tidak ditemukan',
            style: const TextStyle(
                color: Colors.white, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci yang berbeda',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // HASIL PENCARIAN
  // -----------------------------------------------------------
  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            '${_filteredResults.length} produk ditemukan',
            style: const TextStyle(
                color: Colors.white54, fontSize: 13),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _filteredResults.length,
            itemBuilder: (context, index) =>
                _buildProductCard(_filteredResults[index]),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // PRODUCT CARD
  // -----------------------------------------------------------
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
            // Gambar
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(14)),
                    child: product.gambar != null
                        ? Image.network(
                            product.gambar!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  // Badge kategori
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.kategori,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info
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
                              fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rp ${_formatPrice(product.harga.toInt())}',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // Tombol add to cart
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1a2a6c), Color(0xFF2563EB)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.checkroom,
            color: Colors.white30, size: 50),
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