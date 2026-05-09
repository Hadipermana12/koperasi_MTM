import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/loan_provider.dart';
import '../providers/notification_provider.dart';
import '../models/loan_model.dart';

class PinjamanPage extends StatefulWidget {
  const PinjamanPage({super.key});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage> {
  final TextEditingController _amountController = TextEditingController(text: "1.000.000");
  final TextEditingController _purposeController = TextEditingController();
  double _jumlahPembiayaan = 1000000;
  int _jangkaWaktu = 6;
  LoanCategory? _selectedCategory;
  bool _isOverLimit = false;
  bool _isDocumentUploaded = false;
  String _uploadedFileName = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoanProvider>().fetchCategories().then((_) {
        final lp = context.read<LoanProvider>();
        if (lp.error != null) {
          _showErrorDialog(lp.error!);
        }
        final categories = lp.categories;
        if (categories.isNotEmpty) {
          setState(() {
            _selectedCategory = categories.first;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    String text = _amountController.text.replaceAll('.', '').replaceAll('Rp ', '');
    if (text.isEmpty) text = '0';
    double? val = double.tryParse(text);
    if (val != null) {
      double currentLimit = _selectedCategory?.maxAmount ?? 10000000;
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
    final loanProvider = context.watch<LoanProvider>();
    double currentLimit = _selectedCategory?.maxAmount ?? 10000000;
    double interestRate = (_selectedCategory?.interestRate ?? 0.5) / 100;
    
    double marginBulan = interestRate * _jumlahPembiayaan;
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
      body: loanProvider.isLoading && loanProvider.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildLimitBanner(currentLimit),
                  const SizedBox(height: 24),
                  _buildJenisPembiayaan(loanProvider.categories),
                  const SizedBox(height: 24),
                  _buildJumlahPembiayaanSection(currentLimit),
                  const SizedBox(height: 24),
                  _buildTujuanPinjaman(),
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

  Widget _buildTujuanPinjaman() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tujuan Pinjaman',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _purposeController,
            decoration: InputDecoration(
              hintText: 'Contoh: Renovasi rumah, biaya sekolah, dll',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
          ),
        ],
      ),
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
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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
          border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.5)),
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

  Widget _buildJenisPembiayaan(List<LoanCategory> categories) {
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
          categories.isEmpty
            ? const Text("Kategori tidak tersedia", style: TextStyle(color: Colors.grey))
            : SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildTypeCard(category);
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(LoanCategory category) {
    bool isSelected = _selectedCategory?.id == category.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          double limit = category.maxAmount;
          if (_jumlahPembiayaan > limit) {
            _isOverLimit = true;
          } else {
            _isOverLimit = false;
          }
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0F9FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0EA5E9) : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF0284C7) : const Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatCurrency(category.maxAmount),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? const Color(0xFF0369A1) : const Color(0xFF6B7280),
              ),
            ),
          ],
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
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
                      child: TextField(
                        key: const ValueKey('amount_input'),
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32, 
                          fontWeight: FontWeight.bold, 
                          color: _isOverLimit ? Colors.red : const Color(0xFF0284C7)
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '0',
                        ),
                        onChanged: (val) {
                          if (val.isEmpty) return;
                          String clean = val.replaceAll('.', '');
                          double? parsed = double.tryParse(clean);
                          if (parsed != null) {
                            String formatted = _formatNumber(parsed);
                            if (val != formatted) {
                              _amountController.value = TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(offset: formatted.length),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_isOverLimit)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Melebihi limit ${_selectedCategory?.name ?? ""} (${_formatCurrency(currentLimit)})',
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFFE5E7EB),
                    inactiveTrackColor: const Color(0xFFE5E7EB),
                    thumbColor: const Color(0xFF0284C7),
                    overlayColor: const Color(0xFF0284C7).withOpacity(0.1),
                    trackHeight: 10,
                  ),
                  child: Slider(
                    value: _jumlahPembiayaan.clamp(100000.0, currentLimit.clamp(100000.0, double.infinity)),
                    min: 100000,
                    max: currentLimit < 100000 ? 100000 : currentLimit,
                    onChanged: (val) => _updateAmountFromSlider(val),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rp 100rb', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
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
              BoxShadow(color: const Color(0xFF84CC16).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
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
                _buildRincianRow('Bagi Hasil / Margin (${_selectedCategory?.interestRate ?? 0.5}%)', '${_formatCurrency(margin)}/bln', isBold: true),
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

  Future<void> _handleApplyLoan() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_selectedCategory == null) return;
    if (_purposeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan isi tujuan pinjaman')),
        );
        return;
    }

    final loanProvider = context.read<LoanProvider>();
    final authProvider = context.read<AuthProvider>();

    final result = await loanProvider.applyLoan(
      categoryId: _selectedCategory!.id,
      amount: _jumlahPembiayaan,
      tenor: _jangkaWaktu,
      purpose: _purposeController.text,
    );

    if (result != null) {
      // Refresh notifikasi untuk mendapatkan info pengajuan terbaru
      if (mounted) {
        context.read<NotificationProvider>().fetchNotifications();
      }

      // Catat aktifitas pengajuan pembiayaan ke riwayat lokal
      authProvider.addManualTransaction(
        _jumlahPembiayaan,
        'PENGAJUAN ${_selectedCategory!.name.toUpperCase()}',
        ['Tenor $_jangkaWaktu Bulan', 'Tujuan: ${_purposeController.text}']
      );
      _showSuccessDialog();
    } else {
      _showErrorDialog(loanProvider.error ?? 'Gagal mengajukan pinjaman');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Kesalahan'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    final loanProvider = context.watch<LoanProvider>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_isOverLimit || !_isDocumentUploaded || loanProvider.isLoading) ? null : _handleApplyLoan,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14A96B),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: loanProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Ajukan Pembiayaan Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
