import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PinjamanPage extends StatefulWidget {
  const PinjamanPage({super.key});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage> {
  final TextEditingController _amountController = TextEditingController(text: "5.000.000");
  double _jumlahPembiayaan = 5000000;
  int _jangkaWaktu = 6;
  String _jenisPembiayaan = 'Multiguna';
  bool _isOverLimit = false;
  bool _isDocumentUploaded = false;
  String _uploadedFileName = '';

  final Map<String, double> _limits = {
    'Multiguna': 10000000,
    'Syariah': 15000000,
    'Darurat': 10000000, // Based on banner limit in mockup
  };

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    String text = _amountController.text.replaceAll('.', '').replaceAll('Rp ', '');
    if (text.isEmpty) text = '0';
    double? val = double.tryParse(text);
    if (val != null) {
      double currentLimit = _limits[_jenisPembiayaan] ?? 10000000;
      setState(() {
        _jumlahPembiayaan = val;
        _isOverLimit = val > currentLimit;
      });
    }
  }

  String _formatNumber(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _formatCurrency(double amount) {
    return 'Rp ${_formatNumber(amount)}';
  }

  String _formatCurrencyWithDecimal(double amount) {
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String wholeNumber = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $wholeNumber,${parts[1]}';
  }

  void _updateAmountFromSlider(double value) {
    setState(() {
      _jumlahPembiayaan = value;
      _isOverLimit = false;
      String formatted = _formatNumber(value);
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    double currentLimit = _limits[_jenisPembiayaan] ?? 10000000;
    
    double marginBulan = 0.005 * _jumlahPembiayaan; // 0.5%
    double cicilanPokok = _jumlahPembiayaan / _jangkaWaktu;
    double estimasiCicilan = cicilanPokok + marginBulan;
    double totalPembiayaan = _jumlahPembiayaan + (marginBulan * _jangkaWaktu);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        toolbarHeight: 80,
        title: const Column(
          children: [
            Text(
              'Pembiayaan',
              style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 22),
            ),
            Text(
              'Koperasi',
              style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildLimitBanner(currentLimit),
            const SizedBox(height: 24),
            _buildJenisPembiayaan(),
            const SizedBox(height: 24),
            _buildJumlahPembiayaanSection(currentLimit),
            const SizedBox(height: 24),
            _buildJangkaWaktu(),
            const SizedBox(height: 24),
            _buildRincianPembiayaan(marginBulan, cicilanPokok, estimasiCicilan, totalPembiayaan),
            const SizedBox(height: 24),
            _buildUploadSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Dokumen Pendukung',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isDocumentUploaded = true;
                _uploadedFileName = 'dokumen_pembiayaan_${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}.pdf';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isDocumentUploaded ? const Color(0xFF14A96B) : const Color(0xFFE5E7EB),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _isDocumentUploaded ? const Color(0xFFDCFCE7) : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isDocumentUploaded ? Icons.check_rounded : Icons.file_upload_outlined,
                      color: _isDocumentUploaded ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isDocumentUploaded ? 'Dokumen Berhasil Terunggah' : 'Pilih File Dokumen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _isDocumentUploaded ? const Color(0xFF16A34A) : const Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isDocumentUploaded ? _uploadedFileName : 'Upload KTP/Slip Gaji (Maks. 5MB)',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  if (_isDocumentUploaded)
                    const Icon(Icons.refresh_rounded, color: Color(0xFF9CA3AF), size: 20),
                ],
              ),
            ),
          ),
          if (!_isDocumentUploaded)
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 4),
              child: Text(
                '* Wajib mengunggah dokumen pendukung untuk verifikasi',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitBanner(double limit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0EA5E9).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF0369A1), fontSize: 14),
                  children: [
                    const TextSpan(text: 'Sisa Limit Pembiayaan Anda: '),
                    TextSpan(
                      text: _formatCurrency(limit),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildJenisPembiayaan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Jenis Pembiayaan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTypeCard('Multiguna', 'Rp 10.0jt'),
              const SizedBox(width: 12),
              _buildTypeCard('Syariah', 'Rp 15.0jt'),
              const SizedBox(width: 12),
              _buildTypeCard('Darurat', 'Sesuai harga barang'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(String title, String subtitle) {
    bool isSelected = _jenisPembiayaan == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _jenisPembiayaan = title;
            double limit = _limits[title] ?? 10000000;
            if (_jumlahPembiayaan > limit) {
              _isOverLimit = true;
            } else {
              _isOverLimit = false;
            }
          });
        },
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF0EA5E9) : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
            ] : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJumlahPembiayaanSection(double currentLimit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jumlah Pembiayaan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      'Rp ',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                    ),
                    IntrinsicWidth(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold, 
                          color: _isOverLimit ? Colors.red : const Color(0xFF0284C7)
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (val) {
                          String clean = val.replaceAll('.', '');
                          if (clean.isEmpty) clean = '0';
                          double parsed = double.parse(clean);
                          String formatted = _formatNumber(parsed);
                          _amountController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (_isOverLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Melebihi limit ${titleCase(_jenisPembiayaan)} (${_formatCurrency(currentLimit)})',
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFFE5E7EB),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: const Color(0xFF0284C7),
                    overlayColor: const Color(0xFF0284C7).withValues(alpha: 0.1),
                    trackHeight: 10,
                  ),
                  child: Slider(
                    value: _jumlahPembiayaan.clamp(1000000.0, currentLimit),
                    min: 1000000,
                    max: currentLimit,
                    onChanged: (val) => _updateAmountFromSlider(val),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rp 1jt', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    Text(_formatCurrency(currentLimit).replaceAll('Rp ', 'Rp ').replaceAll('.000.000', '.0jt'), style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String titleCase(String text) => text[0].toUpperCase() + text.substring(1);

  Widget _buildJangkaWaktu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jangka Waktu',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTenureCard(3),
              const SizedBox(width: 12),
              _buildTenureCard(6),
              const SizedBox(width: 12),
              _buildTenureCard(12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTenureCard(int value) {
    bool isSelected = _jangkaWaktu == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _jangkaWaktu = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF84CC16) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: isSelected ? [
              BoxShadow(color: const Color(0xFF84CC16).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))
            ] : [],
          ),
          child: Column(
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
              const Text(
                'Bulan',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRincianPembiayaan(double margin, double pokok, double estimasi, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembiayaan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRincianRow('Pokok Pembiayaan', _formatCurrency(_jumlahPembiayaan), isBold: true),
                const SizedBox(height: 12),
                _buildRincianRow('Bagi Hasil / Margin (0.5%)', '${_formatCurrency(margin)}/bln', isBold: true),
                const SizedBox(height: 12),
                _buildRincianRow('Cicilan Pokok per Bulan', _formatCurrencyWithDecimal(pokok), isBold: true),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(),
                ),
                const Text(
                  'Estimasi Cicilan per Bulan',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selama $_jangkaWaktu bulan',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                    Text(
                      _formatCurrencyWithDecimal(estimasi),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFCCB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembiayaan',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF3F6212)),
                      ),
                      Text(
                        _formatCurrency(total),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3F6212)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRincianRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    final authProvider = context.read<AuthProvider>();

    // Catat aktifitas pengajuan pembiayaan ke riwayat
    authProvider.addManualTransaction(
      _jumlahPembiayaan,
      'PENGAJUAN ${_jenisPembiayaan.toUpperCase()}',
      ['Tenor $_jangkaWaktu Bulan', 'Dokumen: $_uploadedFileName']
    );

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
            const Text('Pengajuan Terkirim!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Pengajuan pembiayaan Anda sedang dalam proses verifikasi oleh admin. Kami akan memberikan notifikasi segera.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Kembali ke Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_isOverLimit || !_isDocumentUploaded) ? null : _showSuccessDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14A96B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Ajukan Pembiayaan Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
