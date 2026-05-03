import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

// =============================================================
// MODEL PESAN
// =============================================================
class ChatMessage {
  final String  content;
  final bool    isUser;
  final DateTime time;
  final List<Product>? products; // untuk kartu produk rekomendasi

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? time,
    this.products,
  }) : time = time ?? DateTime.now();
}

// =============================================================
// CHATBOT SCREEN
// =============================================================
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _messageController = TextEditingController();
  final _scrollController  = ScrollController();
  final List<ChatMessage>  _messages = [];
  bool _isTyping = false;

  // Quick action buttons
  final List<Map<String, String>> _quickActions = [
    {'emoji': '👗', 'label': 'Rekomendasi Outfit'},
    {'emoji': '📦', 'label': 'Cek Pesanan'},
    {'emoji': '📏', 'label': 'Panduan Ukuran'},
    {'emoji': '🔄', 'label': 'Info Retur'},
  ];

  // Dummy responses (nanti diganti API Gemini/Claude)
  final Map<String, String> _dummyReplies = {
    'rekomendasi outfit':
        'Tentu! 🔥 Berdasarkan koleksi terbaru VHGH, aku punya beberapa pilihan outfit keren untuk kamu. Cek ini ya:',
    'cek pesanan':
        'Untuk cek pesanan kamu, silakan buka halaman **Pesanan Saya** di menu Profile. Di sana kamu bisa lihat status pesanan secara real-time! 📦',
    'panduan ukuran':
        'Panduan ukuran VHGH:\n\n👕 T-Shirt:\n• S → Dada 88cm\n• M → Dada 92cm\n• L → Dada 96cm\n• XL → Dada 100cm\n• XXL → Dada 104cm\n\nSemua produk VHGH potongan oversized, jadi ukuran M cocok untuk badan standar ya! 😊',
    'info retur':
        'Info Retur VHGH:\n\n✅ Retur bisa dilakukan dalam 7 hari setelah barang diterima\n✅ Produk harus dalam kondisi baru & belum dipakai\n✅ Tag & packaging harus lengkap\n\nUntuk proses retur, hubungi kami via DM Instagram @vhgh.official 📩',
  };

  @override
  void initState() {
    super.initState();
    // Pesan sambutan awal
    _messages.add(ChatMessage(
      content: 'Halo! 👋 Aku VHGH AI Assistant. Aku siap bantu kamu temukan outfit terbaik, cek pesanan, atau jawab pertanyaan seputar VHGH. Ada yang bisa aku bantu? ✨',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(content: userMsg, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulasi delay AI mengetik
    await Future.delayed(const Duration(milliseconds: 1200));

    // Cari dummy reply berdasarkan keyword
    String reply = 'Terima kasih sudah bertanya! 😊 Untuk saat ini fitur AI sedang dalam pengembangan. Silakan hubungi kami via Instagram @vhgh.official untuk bantuan lebih lanjut.';
    List<Product>? rekomendasi;

    final lowerMsg = userMsg.toLowerCase();
    for (final entry in _dummyReplies.entries) {
      if (lowerMsg.contains(entry.key)) {
        reply = entry.value;
        // Kalau rekomendasi outfit, tambahkan kartu produk
        if (entry.key == 'rekomendasi outfit') {
          try {
            final data = await ApiService.getProducts();
            if (data.isNotEmpty) {
              rekomendasi = data
                  .take(3)
                  .map((p) => Product.fromJson(p))
                  .toList();
            }
          } catch (e) {
            // abaikan error
          }
        }
        break;
      }
    }

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        content: reply,
        isUser: false,
        products: rekomendasi,
      ));
    });
    _scrollToBottom();
  }

  void _onQuickAction(String label) {
    _sendMessage(label.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Quick actions (hanya tampil kalau pesan masih sedikit)
          if (_messages.length <= 2) _buildQuickActions(),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Input box
          _buildInputBox(),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // HEADER
  // -----------------------------------------------------------
  Widget _buildHeader() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
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
          children: [
            Row(
              children: [
                // Tombol kembali
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 22),
                  ),
                ),
                const Spacer(),
                // Ikon bintang
                const Text('✦', style: TextStyle(
                    color: Colors.white, fontSize: 22)),
                const SizedBox(width: 6),
                const Text('✦', style: TextStyle(
                    color: AppColors.blue, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),

            // Judul
            const Text(
              'VHGH AI ASSISTANT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Halo! Aku siap bantu kamu temukan outfit terbaik, cek\npesanan, atau jawab pertanyaan seputar VHGH.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // QUICK ACTIONS
  // -----------------------------------------------------------
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _quickActions.map((action) {
          return GestureDetector(
            onTap: () => _onQuickAction(action['label']!),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF12122E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(action['emoji']!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    action['label']!,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -----------------------------------------------------------
  // MESSAGE BUBBLE
  // -----------------------------------------------------------
  Widget _buildMessageBubble(ChatMessage msg) {
    return Column(
      crossAxisAlignment: msg.isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: msg.isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar AI
            if (!msg.isUser) ...[
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('AI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Balon chat
            Flexible(
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: msg.isUser
                      ? AppColors.blue
                      : const Color(0xFF12122E),
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(16),
                    topRight:    const Radius.circular(16),
                    bottomLeft:  Radius.circular(msg.isUser ? 16 : 4),
                    bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                  ),
                  border: msg.isUser
                      ? null
                      : Border.all(color: Colors.white10),
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    color: msg.isUser
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            // Avatar user
            if (msg.isUser) ...[
              const SizedBox(width: 8),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    color: Colors.white70, size: 18),
              ),
            ],
          ],
        ),

        // Kartu produk rekomendasi
        if (msg.products != null && msg.products!.isNotEmpty)
          _buildProductCards(msg.products!),

        // Waktu
        Padding(
          padding: EdgeInsets.only(
            left: msg.isUser ? 0 : 38,
            right: msg.isUser ? 38 : 0,
            bottom: 12,
          ),
          child: Text(
            '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: Colors.white24, fontSize: 10),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // KARTU PRODUK REKOMENDASI
  // -----------------------------------------------------------
  Widget _buildProductCards(List<Product> products) {
    return Container(
      margin: const EdgeInsets.only(left: 38, bottom: 8, top: 4),
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              // TODO: navigate ke detail produk
            },
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1a2a5e),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  // Gambar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12)),
                      child: product.gambar != null
                          ? Image.network(
                              product.gambar!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(
                                    child: Icon(Icons.checkroom,
                                        color: Colors.white30,
                                        size: 36),
                                  ),
                            )
                          : const Center(
                              child: Icon(Icons.checkroom,
                                  color: Colors.white30, size: 36),
                            ),
                    ),
                  ),

                  // Info
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rp ${_formatPrice(product.harga.toInt())}',
                          style: const TextStyle(
                              color: AppColors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // -----------------------------------------------------------
  // TYPING INDICATOR
  // -----------------------------------------------------------
  Widget _buildTypingIndicator() {
    return Row(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('AI',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF12122E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(0),
              const SizedBox(width: 4),
              _dot(200),
              const SizedBox(width: 4),
              _dot(400),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, val, __) => Opacity(
        opacity: val,
        child: Container(
          width: 7, height: 7,
          decoration: const BoxDecoration(
            color: Colors.white54,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // INPUT BOX
  // -----------------------------------------------------------
  Widget _buildInputBox() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D2B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Field input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF12122E),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.auto_awesome,
                      color: Colors.white38, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        hintStyle: TextStyle(
                            color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      onSubmitted: _sendMessage,
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  // Tombol edit/clear
                  IconButton(
                    icon: const Icon(Icons.edit,
                        color: Colors.white38, size: 18),
                    onPressed: () => _messageController.clear(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Tombol kirim
          GestureDetector(
            onTap: () => _sendMessage(_messageController.text),
            child: Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(Icons.send,
                  color: Colors.white, size: 20),
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