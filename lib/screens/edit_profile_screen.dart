import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _namaController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _teleponController  = TextEditingController();
  final _alamatController   = TextEditingController();

  bool _isLoading  = true;
  bool _isSaving   = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await ApiService.profile();
      if (result['status'] == true) {
        final user = result['user'];
        setState(() {
          _namaController.text    = user['name']       ?? '';
          _emailController.text   = user['email']      ?? '';
          _teleponController.text = user['no_telepon'] ?? '';
          _alamatController.text  = user['alamat']     ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final result = await ApiService.updateProfile(
        name:       _namaController.text.trim(),
        noTelepon:  _teleponController.text.trim(),
        alamat:     _alamatController.text.trim(),
      );

      if (result['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil berhasil diupdate!'),
              backgroundColor: AppColors.green,
            ),
          );
          Navigator.pop(context, true); // return true = ada perubahan
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal update profil'),
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

    setState(() => _isSaving = false);
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildAvatarSection(),
                        const SizedBox(height: 28),
                        _buildFormSection(),
                        const SizedBox(height: 28),
                        _buildSaveButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
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
            const SizedBox(width: 14),
            const Text(
              'Edit Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // AVATAR SECTION
  // -----------------------------------------------------------
  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          children: [
            // Avatar
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF12122E),
                border: Border.all(color: AppColors.blue, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.person,
                  color: Colors.white54, size: 50),
            ),

            // Edit button
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: () {
                  // TODO: Pilih foto dari galeri
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur ganti foto segera hadir!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.bgDark, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _namaController.text.isNotEmpty
              ? _namaController.text
              : 'Pengguna VHGH',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _emailController.text,
          style: const TextStyle(
              color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // FORM SECTION
  // -----------------------------------------------------------
  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF12122E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                width: 4, height: 16,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Informasi Pribadi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nama
          _buildTextField(
            controller: _namaController,
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          // Email (readonly)
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Email tidak dapat diubah',
            icon: Icons.email_outlined,
            readOnly: true,
          ),
          const SizedBox(height: 16),

          // No Telepon
          _buildTextField(
            controller: _teleponController,
            label: 'Nomor Telepon',
            hint: '+62 812-xxxx-xxxx',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),

          // Alamat
          _buildTextField(
            controller: _alamatController,
            label: 'Alamat',
            hint: 'Masukkan alamat lengkap',
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: readOnly
                ? const Color(0xFF0A0A1F)
                : const Color(0xFF1a1a3e),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: readOnly ? Colors.white10 : Colors.white24,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(
              color: readOnly ? Colors.white38 : Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Colors.white24, fontSize: 13),
              prefixIcon: Icon(icon,
                  color: readOnly
                      ? Colors.white24
                      : AppColors.blue,
                  size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              suffixIcon: readOnly
                  ? const Icon(Icons.lock_outline,
                      color: Colors.white24, size: 16)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // SAVE BUTTON
  // -----------------------------------------------------------
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          disabledBackgroundColor: AppColors.blue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined,
                      color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}