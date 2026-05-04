import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments
            as Map<String, dynamic>? ??
        {};

    final kodeOrder = order['kode_order']?.toString() ?? '-';
    final status    = order['status']?.toString() ?? 'pending';
    final total     = double.tryParse(order['total_harga'].toString()) ?? 0;
    final kurir     = order['kurir']?.toString() ?? '-';
    final metode    = order['metode_pembayaran']?.toString() ?? '-';
    final alamat    = order['alamat_pengiriman']?.toString() ?? '-';
    final tanggal   = order['created_at']?.toString() ?? '-';
    final items     = order['items'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          _buildAppBar(context, kodeOrder),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusCard(status, tanggal),
                  const SizedBox(height: 14),
                  _buildTracking(status),
                  const SizedBox(height: 14),
                  _buildShippingInfo(alamat, kurir),
                  const SizedBox(height: 14),
                  _buildProductList(items),
                  const SizedBox(height: 14),
                  _buildPaymentSummary(total, metode, kurir),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, status),
        ],
      ),
    );
  }

  // APP BAR
  Widget _buildAppBar(BuildContext context, String kodeOrder) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
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
            const SizedBox(width: 12),
            const Text('Detail Pesanan',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: kodeOrder));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Kode order disalin!'),
                    backgroundColor: AppColors.blue,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF12122E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Text('#$kodeOrder',
                        style: const TextStyle(
                            color: AppColors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.copy,
                        color: Colors.white38, size: 13),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STATUS CARD
  Widget _buildStatusCard(String status, String tanggal) {
    final info = _statusInfo(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (info['color'] as Color).withOpacity(0.15),
              border: Border.all(
                  color: (info['color'] as Color).withOpacity(0.4)),
            ),
            child: Icon(info['icon'] as IconData,
                color: info['color'] as Color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(info['label'] as String,
                    style: TextStyle(
                        color: info['color'] as Color,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(info['desc'] as String,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(tanggal,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  // TRACKING
  Widget _buildTracking(String status) {
    final steps = [
      'Diterima', 'Diproses', 'Dikirim', 'Di Jalan', 'Selesai'
    ];
    final statusMap = {
      'pending': 0, 'paid': 1, 'processing': 1,
      'shipped': 2, 'delivered': 4,
    };
    final current = status == 'cancelled'
        ? -1
        : (statusMap[status.toLowerCase()] ?? 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Progress Pesanan',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length, (i) {
              final done    = i <= current && current >= 0;
              final isCur   = i == current && current >= 0;
              final isLast  = i == steps.length - 1;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? AppColors.green
                                  : const Color(0xFF1a1a3e),
                              border: Border.all(
                                color: done
                                    ? AppColors.green
                                    : Colors.white24,
                                width: isCur ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              done ? Icons.check : Icons.circle,
                              color: done
                                  ? Colors.white
                                  : Colors.white24,
                              size: done ? 14 : 7,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(steps[i],
                              style: TextStyle(
                                color: done
                                    ? Colors.white
                                    : Colors.white38,
                                fontSize: 8,
                                fontWeight: isCur
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.only(bottom: 20),
                          color: i < current
                              ? AppColors.green
                              : Colors.white12,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // SHIPPING INFO
  Widget _buildShippingInfo(String alamat, String kurir) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Info Pengiriman'),
          const SizedBox(height: 14),
          _infoRow(Icons.local_shipping_outlined, 'Kurir', kurir),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on_outlined, 'Alamat', alamat),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.blue, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  // PRODUCT LIST
  Widget _buildProductList(List items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Produk (${items.length})'),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((e) {
            final i    = e.key;
            final item = e.value as Map<String, dynamic>;
            final isLast = i == items.length - 1;
            return Column(
              children: [
                Row(
                  children: [
                    // Gambar
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF1a2a6c), Color(0xFF2563EB)]),
                      ),
                      child: item['gambar'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(item['gambar'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.checkroom,
                                          color: Colors.white30, size: 26)),
                            )
                          : const Icon(Icons.checkroom,
                              color: Colors.white30, size: 26),
                    ),
                    const SizedBox(width: 12),

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name']?.toString() ?? '-',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Size ${item['ukuran']}',
                                    style: const TextStyle(
                                        color: AppColors.blue,
                                        fontSize: 10)),
                              ),
                              const SizedBox(width: 6),
                              Text('x${item['jumlah']}',
                                  style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Subtotal
                    Text(
                      'Rp ${_fmt(double.tryParse(item['subtotal']?.toString() ?? '0')?.toInt() ?? 0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 12),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  // PAYMENT SUMMARY
  Widget _buildPaymentSummary(double total, String metode, String kurir) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Ringkasan Pembayaran'),
          const SizedBox(height: 14),
          _sumRow('Subtotal', 'Rp ${_fmt(total.toInt())}'),
          const SizedBox(height: 8),
          _sumRow('Ongkir ($kurir)', 'Gratis',
              valueColor: AppColors.green),
          const SizedBox(height: 8),
          _sumRow('Metode Bayar', metode),
          const Divider(color: Colors.white10, height: 20),
          _sumRow('Total', 'Rp ${_fmt(total.toInt())}',
              bold: true, valueColor: AppColors.blue, fontSize: 15),
        ],
      ),
    );
  }

  Widget _sumRow(String label, String value,
      {Color? valueColor, bool bold = false, double fontSize = 13}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: bold ? Colors.white : Colors.white60,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: fontSize,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  // BOTTOM BAR
  Widget _buildBottomBar(BuildContext context, String status) {
    final showBeli   = status == 'delivered';
    final showCancel = status == 'pending' || status == 'processing';
    if (!showBeli && !showCancel) return const SizedBox();

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
          if (showBeli)
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1D4ED8), AppColors.blue]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Beli Lagi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          if (showCancel)
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.4)),
                  ),
                  child: const Center(
                    child: Text('Batalkan Pesanan',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // HELPERS
  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Map<String, dynamic> _statusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return {'label': 'Menunggu Konfirmasi', 'desc': 'Pesanan sedang menunggu konfirmasi toko', 'icon': Icons.schedule, 'color': Colors.orange};
      case 'paid':
      case 'processing':
        return {'label': 'Sedang Diproses', 'desc': 'Pesanan sedang dipersiapkan', 'icon': Icons.bolt, 'color': Colors.orange};
      case 'shipped':
        return {'label': 'Dalam Pengiriman', 'desc': 'Pesanan sedang dalam perjalanan', 'icon': Icons.local_shipping_outlined, 'color': AppColors.blue};
      case 'delivered':
        return {'label': 'Pesanan Selesai', 'desc': 'Pesanan telah diterima', 'icon': Icons.check_circle_outline, 'color': AppColors.green};
      case 'cancelled':
        return {'label': 'Pesanan Dibatalkan', 'desc': 'Pesanan telah dibatalkan', 'icon': Icons.cancel_outlined, 'color': Colors.red};
      default:
        return {'label': 'Pending', 'desc': 'Menunggu konfirmasi', 'icon': Icons.schedule, 'color': Colors.grey};
    }
  }

  String _fmt(int price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}jt';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}k';
    return price.toString();
  }
}