import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _npkController = TextEditingController();
  final _deptController = TextEditingController();
  final _accountController = TextEditingController();
  final _addressController = TextEditingController();
  final _ktpController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  List<Offset?> _signaturePoints = [];

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _npkController.text.isEmpty ||
        _deptController.text.isEmpty ||
        _accountController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _ktpController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data wajib diisi')),
      );
      return;
    }

    if (_signaturePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanda tangan wajib diisi')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    await authProvider.register({
      'npk': _npkController.text,
      'name': _nameController.text,
      'password': _passwordController.text,
      'ktp': _ktpController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'dept': _deptController.text,
      'accountNumber': _accountController.text,
      'registeredAt': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF14A96B), size: 80),
            const SizedBox(height: 20),
            const Text('Pendaftaran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Data pendaftaran anggota telah kami terima. Akun Anda akan aktif setelah divalidasi oleh Admin Koperasi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to login
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _npkController.dispose();
    _deptController.dispose();
    _accountController.dispose();
    _addressController.dispose();
    _ktpController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Daftar Anggota Koperasi', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Personal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            const SizedBox(height: 20),
            _buildInputField(label: 'Nama Lengkap', hint: 'Sesuai KTP', controller: _nameController, icon: Icons.person_outline),
            _buildInputField(label: 'No. KTP', hint: '16 Digit NIK', controller: _ktpController, icon: Icons.badge_outlined, keyboardType: TextInputType.number),
            _buildInputField(label: 'Alamat Domisili', hint: 'Alamat Lengkap', controller: _addressController, icon: Icons.home_outlined, maxLines: 2),
            _buildInputField(label: 'No. Handphone', hint: '0812xxxx', controller: _phoneController, icon: Icons.phone_android_outlined, keyboardType: TextInputType.phone),

            const SizedBox(height: 32),
            const Text('Informasi Pekerjaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            const SizedBox(height: 20),
            _buildInputField(label: 'NPK', hint: 'Nomor Pokok Karyawan', controller: _npkController, icon: Icons.work_outline),
            _buildInputField(label: 'Bagian / Departemen', hint: 'Contoh: Finance / Produksi', controller: _deptController, icon: Icons.groups_outlined),

            const SizedBox(height: 32),
            const Text('Informasi Rekening & Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
            const SizedBox(height: 20),
            _buildInputField(label: 'Nomor Rekening', hint: 'Untuk pencairan dana', controller: _accountController, icon: Icons.account_balance_wallet_outlined, keyboardType: TextInputType.number),
            _buildInputField(label: 'Buat Password', hint: 'Minimal 6 karakter', controller: _passwordController, icon: Icons.lock_outline, isPassword: true),

            const SizedBox(height: 32),
            const Text('Tanda Tangan Anggota', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
            const SizedBox(height: 12),
            _buildSignaturePad(),

            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword && !_isPasswordVisible,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF0284C7), size: 20),
              suffixIcon: isPassword ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey, size: 20),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ) : null,
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0284C7))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                _signaturePoints.add(details.localPosition);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _signaturePoints.add(details.localPosition);
              });
            },
            onPanEnd: (details) => _signaturePoints.add(null),
            child: CustomPaint(
              painter: SignaturePainter(points: _signaturePoints),
              size: Size.infinite,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: TextButton.icon(
              onPressed: () => setState(() => _signaturePoints = []),
              icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
              label: const Text('Reset', style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ),
          if (_signaturePoints.isEmpty)
            const Center(child: Text('Tanda tangan langsung di sini', style: TextStyle(color: Colors.grey, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: auth.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Daftar Anggota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.black..strokeCap = StrokeCap.round..strokeWidth = 3.0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
