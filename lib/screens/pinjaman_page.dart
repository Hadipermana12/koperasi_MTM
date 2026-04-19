import 'package:flutter/material.dart';

class PinjamanPage extends StatefulWidget {
  const PinjamanPage({super.key});

  @override
  State<PinjamanPage> createState() => _PinjamanPageState();
}

class _PinjamanPageState extends State<PinjamanPage> {
  double _jumlahPinjaman = 5000000;
  int _jangkaWaktu = 6;
  final double _bungaPerBulan = 0.005; // 0.5%
  final TextEditingController _jumlahController = TextEditingController(text: "5.000.000");

  @override
  void dispose() {
    _jumlahController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    String formatted = amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  String _formatCurrencyWithDecimal(double amount) {
    String formatted = amount.toStringAsFixed(2);
    List<String> parts = formatted.split('.');
    String wholeNumber = parts[0].replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return 'Rp $wholeNumber,${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    double totalBunga = _jumlahPinjaman * _bungaPerBulan * _jangkaWaktu;
    double totalPembayaran = _jumlahPinjaman + totalBunga;
    double cicilanPerBulan = totalPembayaran / _jangkaWaktu;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pinjaman Koperasi',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLimitInfo(),
            _buildJumlahPinjamanInput(),
            const Divider(color: Color(0xFFEEEEEE), thickness: 8),
            _buildJangkaWaktuSelector(),
            _buildRincianPinjaman(totalBunga, cicilanPerBulan),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitInfo() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD6E4FF)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF2F6BFF), size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sisa Limit Pinjaman Anda',
                  style: TextStyle(color: Color(0xFF1B3D7B), fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Rp 10.000.000',
                  style: TextStyle(color: Color(0xFF2F6BFF), fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJumlahPinjamanInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Jumlah Pinjaman',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                'Rp ',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
              ),
              IntrinsicWidth(
                child: TextFormField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) {
                    String clean = val.replaceAll(RegExp(r'[^0-9]'), '');
                    if (clean.isEmpty) clean = '0';
                    
                    double parsed = double.parse(clean);
                    setState(() {
                      _jumlahPinjaman = parsed;
                    });

                    // Format ribuan
                    String formatted = parsed.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
                    _jumlahController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ketik atau geser slider untuk mengatur jumlah',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF14A96B),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xFF14A96B),
              overlayColor: const Color(0xFF14A96B).withOpacity(0.2),
              trackHeight: 8,
            ),
            child: Slider(
              value: _jumlahPinjaman.clamp(1000000.0, 10000000.0),
              min: 1000000,
              max: 10000000,
              divisions: 90,
              onChanged: (value) {
                setState(() {
                  _jumlahPinjaman = value;
                  String formatted = value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
                  _jumlahController.text = formatted;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Rp 1jt', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Rp 10jt', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildJangkaWaktuSelector() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jangka Waktu',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDurationOption(3),
              const SizedBox(width: 12),
              _buildDurationOption(6),
              const SizedBox(width: 12),
              _buildDurationOption(12),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDurationOption(int months) {
    bool isSelected = _jangkaWaktu == months;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _jangkaWaktu = months;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF14A96B) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF14A96B) : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: const Color(0xFF14A96B).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            '$months Bulan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRincianPinjaman(double totalBunga, double cicilanPerBulan) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF2FFF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7F3DB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.receipt_long_outlined, color: Color(0xFF14A96B), size: 20),
                SizedBox(width: 8),
                Text(
                  'Rincian Pinjaman',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRincianRow('Pokok Pinjaman', _formatCurrency(_jumlahPinjaman)),
                  const SizedBox(height: 12),
                  _buildRincianRow('Bunga (0.5% per bulan)', _formatCurrency(totalBunga)),
                  const SizedBox(height: 12),
                  _buildRincianRow('Jangka Waktu', '$_jangkaWaktu Bulan'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFFEEEEEE), height: 1),
                  ),
                  const Text(
                    'Estimasi Cicilan per Bulan',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrencyWithDecimal(cicilanPerBulan),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '* Perhitungan ini bersifat estimasi dan dapat berubah',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRincianRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _tampilkanKonfirmasiPinjaman();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14A96B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.check_circle_outline, size: 22),
              label: const Text('Ajukan Pinjaman Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Dengan mengajukan, Anda menyetujui syarat dan ketentuan pinjaman koperasi',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _tampilkanKonfirmasiPinjaman() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Pinjaman', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Apakah Anda yakin ingin mengajukan pinjaman sebesar ${_formatCurrency(_jumlahPinjaman)} dengan jangka waktu $_jangkaWaktu bulan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog konfirmasi
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.all(24),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: Color(0xFF14A96B), size: 72),
                          const SizedBox(height: 24),
                          const Text(
                            'Berhasil Pinjam!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Pengajuan pinjaman koperasi Anda telah diterima dan akan segera diproses oleh tim kami.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); 
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF14A96B),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Kembali ke Beranda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14A96B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, Ajukan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
