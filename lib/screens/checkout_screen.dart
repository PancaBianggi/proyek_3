import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Controllers Data Pembeli
  final _namaController = TextEditingController();
  final _teleponController = TextEditingController();
  final _emailController = TextEditingController();

  // Controllers Alamat
  final _namaPenerimaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _kotaController = TextEditingController();
  final _kodePosController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _catatanController = TextEditingController();

  // Pilihan kurir & metode bayar
  String _selectedKurir = 'JNE';
  String _selectedMetode = 'Transfer';

  final List<String> _kurirList = ['JNE', 'J&T', 'SiCepat', 'Anteraja'];
  final List<String> _metodeList = ['Transfer', 'COD', 'E-Wallet'];

  // Data keranjang
  List<dynamic> _cartItems = [];
  double _total = 0;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _namaPenerimaController.dispose();
    _alamatController.dispose();
    _kotaController.dispose();
    _kodePosController.dispose();
    _provinsiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    try {
      final result = await ApiService.getCart();
      if (result['status'] == true) {
        setState(() {
          _cartItems = result['items'] ?? [];
          _total = double.parse(result['total'].toString());
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final result = await ApiService.profile();
      if (result['status'] == true) {
        final user = result['user'];
        setState(() {
          _namaController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _teleponController.text      = user['no_telepon'] ?? '';
          _namaPenerimaController.text = user['name'] ?? '';
          _alamatController.text       = user['alamat']     ?? '';
        });
      }
    } catch (e) {
      // abaikan error
    }
  }

  Future<void> _prosesCheckout() async {
    // Validasi input
    if (_namaController.text.isEmpty ||
        _teleponController.text.isEmpty ||
        _namaPenerimaController.text.isEmpty ||
        _alamatController.text.isEmpty ||
        _kotaController.text.isEmpty ||
        _provinsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data yang wajib diisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Gabungkan alamat lengkap
      final alamatLengkap =
          '${_namaPenerimaController.text}\n'
          '${_alamatController.text}\n'
          '${_kotaController.text}, ${_provinsiController.text} ${_kodePosController.text}\n'
          'Tel: ${_teleponController.text}'
          '${_catatanController.text.isNotEmpty ? '\nCatatan: ${_catatanController.text}' : ''}';

      final result = await ApiService.createOrder(
        alamatLengkap,
        _selectedKurir,
        _selectedMetode,
      );

      if (result['status'] == true) {
        if (mounted) {
          // Navigate ke halaman sukses
          Navigator.pushReplacementNamed(
            context,
            '/order-success',
            arguments: {
              'kode_order': result['kode_order'],
              'total': result['total'],
            },
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal membuat pesanan'),
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

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // App Bar
          _buildAppBar(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.blue),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ringkasan produk
                        _buildProductSummary(),
                        const SizedBox(height: 20),

                        // Data Pembeli
                        _buildSectionTitle('DATA PEMBELI'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _namaController,
                          'NAMA LENGKAP',
                          'Stylish User',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _teleponController,
                                'NO. TELEPON',
                                '+62 812-xxxx',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _emailController,
                                'EMAIL',
                                'user@mail.com',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Alamat Pengiriman
                        _buildSectionTitle('ALAMAT PENGIRIMAN'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _namaPenerimaController,
                          'NAMA PENERIMA',
                          'Stylish User',
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _alamatController,
                          'ALAMAT LENGKAP',
                          'Jl. Contoh No. 12, RT 03/RW 05',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _kotaController,
                                'KOTA',
                                'Bandung',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _kodePosController,
                                'KODE POS',
                                '40123',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _provinsiController,
                          'PROVINSI',
                          'Jawa Barat',
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(
                          _catatanController,
                          'CATATAN UNTUK KURIR (OPSIONAL)',
                          'Contoh: Titip di satpam',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        // Pilih Kurir
                        _buildSectionTitle('PILIH KURIR'),
                        const SizedBox(height: 12),
                        _buildKurirSelector(),
                        const SizedBox(height: 20),

                        // Metode Pembayaran
                        _buildSectionTitle('METODE PEMBAYARAN'),
                        const SizedBox(height: 12),
                        _buildMetodeSelector(),
                        const SizedBox(height: 20),

                        // Total
                        _buildTotalSection(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
          ),

          // Tombol Bayar
          _buildBottomBar(),
        ],
      ),
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
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'PEMBAYARAN',
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
  // RINGKASAN PRODUK
  // -----------------------------------------------------------
  Widget _buildProductSummary() {
    if (_cartItems.isEmpty) return const SizedBox();

    return Column(
      children: _cartItems.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF12122E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              // Gambar produk
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item['gambar'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['gambar'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.checkroom,
                            color: Colors.white30,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.checkroom,
                        color: Colors.white54,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 12),

              // Info produk
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ukuran ${item['ukuran']} · Hitam · Qty ${item['jumlah']}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              // Harga
              Text(
                'Rp ${_formatPrice(double.parse(item['subtotal'].toString()).toInt())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // -----------------------------------------------------------
  // SECTION TITLE
  // -----------------------------------------------------------
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // TEXT FIELD
  // -----------------------------------------------------------
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF12122E),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // KURIR SELECTOR
  // -----------------------------------------------------------
  Widget _buildKurirSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _kurirList.map((kurir) {
        final isSelected = _selectedKurir == kurir;
        return GestureDetector(
          onTap: () => setState(() => _selectedKurir = kurir),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue : const Color(0xFF12122E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.blue : Colors.white24,
              ),
            ),
            child: Text(
              kurir,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // -----------------------------------------------------------
  // METODE PEMBAYARAN SELECTOR
  // -----------------------------------------------------------
  Widget _buildMetodeSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _metodeList.map((metode) {
        final isSelected = _selectedMetode == metode;
        return GestureDetector(
          onTap: () => setState(() => _selectedMetode = metode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.blue : const Color(0xFF12122E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.blue : Colors.white24,
              ),
            ),
            child: Text(
              metode,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // -----------------------------------------------------------
  // TOTAL SECTION
  // -----------------------------------------------------------
  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              Text(
                'Rp ${_formatPrice(_total.toInt())}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ongkir ($_selectedKurir)',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const Text(
                'Gratis',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rp ${_formatPrice(_total.toInt())}',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
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
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _prosesCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
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
