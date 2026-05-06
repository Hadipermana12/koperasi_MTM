import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import '../providers/auth_provider.dart';
import '../services/address_service.dart';

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

  final AddressService _addressService = AddressService();

  List<Map<String, dynamic>> _provinsiList = [];
  List<Map<String, dynamic>> _kabupatenList = [];
  List<Map<String, dynamic>> _kecamatanList = [];
  List<Map<String, dynamic>> _kelurahanList = [];

  Map<String, dynamic>? _selectedProvinsi;
  Map<String, dynamic>? _selectedKabupaten;
  Map<String, dynamic>? _selectedKecamatan;
  Map<String, dynamic>? _selectedKelurahan;
  
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    _loadProvinsi();
  }

  Future<void> _loadProvinsi() async {
    setState(() => _isLoadingAddress = true);
    final data = await _addressService.getProvinsi();
    if (mounted) {
      setState(() {
        _provinsiList = data;
        _isLoadingAddress = false;
      });
    }
  }

  void _onProvinsiChanged(Map<String, dynamic>? val) async {
    setState(() {
      _selectedProvinsi = val;
      _selectedKabupaten = null;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kabupatenList = [];
      _kecamatanList = [];
      _kelurahanList = [];
    });
    if (val != null) {
      setState(() => _isLoadingAddress = true);
      final data = await _addressService.getKabupaten(val['id']);
      if (mounted) {
        setState(() {
          _kabupatenList = data;
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _onKabupatenChanged(Map<String, dynamic>? val) async {
    setState(() {
      _selectedKabupaten = val;
      _selectedKecamatan = null;
      _selectedKelurahan = null;
      _kecamatanList = [];
      _kelurahanList = [];
    });
    if (val != null) {
      setState(() => _isLoadingAddress = true);
      final data = await _addressService.getKecamatan(val['id']);
      if (mounted) {
        setState(() {
          _kecamatanList = data;
          _isLoadingAddress = false;
        });
      }
    }
  }

  void _onKecamatanChanged(Map<String, dynamic>? val) async {
    setState(() {
      _selectedKecamatan = val;
      _selectedKelurahan = null;
      _kelurahanList = [];
    });
    if (val != null) {
      setState(() => _isLoadingAddress = true);
      final data = await _addressService.getKelurahan(val['id']);
      if (mounted) {
        setState(() {
          _kelurahanList = data;
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _npkController.text.isEmpty ||
        _deptController.text.isEmpty ||
        _accountController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedProvinsi == null ||
        _selectedKabupaten == null ||
        _selectedKecamatan == null ||
        _selectedKelurahan == null ||
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

    final String combinedAddress = [
      _addressController.text.trim(),
      _selectedKelurahan?['name'] != null ? 'Kel. ${_selectedKelurahan!['name']}' : null,
      _selectedKecamatan?['name'] != null ? 'Kec. ${_selectedKecamatan!['name']}' : null,
      _selectedKabupaten?['name'],
      _selectedProvinsi?['name'] != null ? 'Prov. ${_selectedProvinsi!['name']}' : null,
    ].where((e) => e != null && e!.isNotEmpty).join(', ');

    final signatureBase64 = await _getSignatureBase64();
    if (signatureBase64 == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanda tangan gagal diproses')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.register({
        // API Requirements
        'npk': _npkController.text,
        'name': _nameController.text,
        'password': _passwordController.text,
        'phoneNumber': _phoneController.text,
        'bankInfo': {
          'bankName': 'Koperasi', // Default as it's not in the UI
          'accountNumber': _accountController.text,
          'accountName': _nameController.text,
        },
        // Local/Legacy data for profile page
        'noKtp': _ktpController.text,
        'address': combinedAddress,
        'section': _deptController.text,
        'accountNumber': _accountController.text,
        'registeredAt': DateTime.now().toIso8601String(),
        'signature': signatureBase64,
      });

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
    }
  }

  Future<String?> _getSignatureBase64() async {
    if (_signaturePoints.isEmpty) return null;
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 150), Paint()..color = Colors.white);
      final painter = SignaturePainter(points: _signaturePoints);
      painter.paint(canvas, const Size(300, 150));
      final picture = recorder.endRecording();
      final image = await picture.toImage(300, 150);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final base64String = base64Encode(byteData.buffer.asUint8List());
        return 'data:image/png;base64,$base64String';
      }
    } catch (e) {
      debugPrint("Error generating signature image: $e");
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Pendaftaran Gagal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Color(0xFF4B5563))),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
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
            
            const Text('Alamat Lengkap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
            const SizedBox(height: 8),
            _buildDropdown(label: 'Provinsi', hint: 'Pilih Provinsi', items: _provinsiList, selectedValue: _selectedProvinsi, onChanged: _onProvinsiChanged, icon: Icons.map_outlined),
            _buildDropdown(label: 'Kabupaten/Kota', hint: 'Pilih Kabupaten/Kota', items: _kabupatenList, selectedValue: _selectedKabupaten, onChanged: _onKabupatenChanged, icon: Icons.location_city_outlined),
            _buildDropdown(label: 'Kecamatan', hint: 'Pilih Kecamatan', items: _kecamatanList, selectedValue: _selectedKecamatan, onChanged: _onKecamatanChanged, icon: Icons.holiday_village_outlined),
            _buildDropdown(label: 'Kelurahan/Desa', hint: 'Pilih Kelurahan/Desa', items: _kelurahanList, selectedValue: _selectedKelurahan, onChanged: (val) => setState(() => _selectedKelurahan = val), icon: Icons.home_work_outlined),
            if (_isLoadingAddress) const Padding(padding: EdgeInsets.only(bottom: 16), child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
            
            _buildInputField(label: 'Jalan/Blok/RT/RW', hint: 'Detail Jalan / Gang / Nomor Rumah', controller: _addressController, icon: Icons.home_outlined, maxLines: 2),
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
            _buildSignatureSection(),

            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic>? selectedValue,
    required ValueChanged<Map<String, dynamic>?> onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4B5563))),
          const SizedBox(height: 8),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedValue,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(icon, color: const Color(0xFF0284C7), size: 20),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0284C7))),
            ),
            items: items.map((item) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: item,
                child: Text(item['name'], style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
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

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_signaturePoints.isNotEmpty) ...[
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: SignaturePainter(points: _signaturePoints),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _showSignatureDialog,
            icon: const Icon(Icons.draw, color: Color(0xFF0284C7)),
            label: Text(
              _signaturePoints.isEmpty ? 'Buat Tanda Tangan' : 'Ubah Tanda Tangan',
              style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0284C7)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showSignatureDialog() {
    List<Offset?> tempPoints = List.from(_signaturePoints);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Buat Tanda Tangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 250,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onPanStart: (details) {
                          setStateDialog(() {
                            tempPoints.add(details.localPosition);
                          });
                        },
                        onPanUpdate: (details) {
                          setStateDialog(() {
                            tempPoints.add(details.localPosition);
                          });
                        },
                        onPanEnd: (details) => tempPoints.add(null),
                        child: CustomPaint(
                          painter: SignaturePainter(points: tempPoints),
                          size: Size.infinite,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh, color: Colors.red, size: 16),
                          label: const Text('Reset', style: TextStyle(color: Colors.red)),
                          onPressed: () => setStateDialog(() => tempPoints.clear()),
                        ),
                      ),
                      if (tempPoints.isEmpty)
                        const Center(child: Text('Tanda tangan di sini', style: TextStyle(color: Colors.grey))),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _signaturePoints = List.from(tempPoints);
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      }
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
