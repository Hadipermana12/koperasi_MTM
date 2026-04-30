import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/car_model.dart';

class SewaMobilPage extends StatefulWidget {
  const SewaMobilPage({super.key});

  @override
  State<SewaMobilPage> createState() => _SewaMobilPageState();
}

class _SewaMobilPageState extends State<SewaMobilPage> {
  DateTime? _selectedDate;
  int _selectedDurasi = 12;

  final List<CarModel> _cars = [
    CarModel(
      id: 'xenia_2022',
      name: 'Daihatsu Xenia 2022',
      type: 'MPV',
      pricePerDay: 300000,
      image: 'assets/images/daihatsu.jpg',
      transmission: 'Manual/Matic',
      capacity: 7,
      fuel: 'Bensin',
    ),
    CarModel(
      id: 'agya_2012',
      name: 'Toyota Agya 2012',
      type: 'City Car',
      pricePerDay: 250000,
      image: 'assets/images/agnia.jpg',
      transmission: 'Manual',
      capacity: 5,
      fuel: 'Bensin',
    ),
  ];

  String _formatDate(DateTime date) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Sewa Mobil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeaderSelection(),
          _buildInfoBanner(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _cars.length,
              itemBuilder: (context, index) => _buildCarCard(_cars[index]),
            ),
          ),
          _buildContactAdmin(),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.payment_rounded, color: Color(0xFF0284C7), size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Pembayaran sewa mobil menggunakan sistem Potong Gaji atau Transfer Bank.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF075985)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF0284C7),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null ? 'Pilih Tanggal' : _formatDate(_selectedDate!),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [12, 24, 48].map((h) => _buildDurasiButton(h)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurasiButton(int hours) {
    final isSelected = _selectedDurasi == hours;
    return GestureDetector(
      onTap: () => setState(() => _selectedDurasi = hours),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text('${hours}j', style: TextStyle(color: isSelected ? const Color(0xFF0284C7) : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildCarCard(CarModel car) {
    final double totalHarga = car.pricePerDay * (_selectedDurasi / 12);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        children: [
          ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.asset(car.image, height: 160, width: double.infinity, fit: BoxFit.cover)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(car.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('Rp ${_formatNumber(totalHarga.toInt())}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF14A96B))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSpecInfo(Icons.settings_outlined, car.transmission),
                    const SizedBox(width: 16),
                    _buildSpecInfo(Icons.people_outline_rounded, '${car.capacity} Kursi'),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _showBookingOptions(car, totalHarga),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: const Text('Sewa Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecInfo(IconData icon, String label) => Row(children: [Icon(icon, size: 16, color: Colors.grey[600]), const SizedBox(width: 4), Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13))]);

  void _showBookingOptions(CarModel car, double total) {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih tanggal sewa')));
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Text('Metode Pembayaran', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total: Rp ${_formatNumber(total.toInt())}', style: const TextStyle(fontSize: 16, color: Color(0xFF14A96B), fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            _buildPaymentOption(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Potong Gaji',
              subtitle: 'Pembayaran akan dipotong dari gaji bulan depan.',
              onTap: () => _processBooking(car, 'Potong Gaji'),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              icon: Icons.account_balance_outlined,
              title: 'Transfer Bank',
              subtitle: 'Permata Bank: 04124428500\nan. KOPKAR MENARA MAKMUR ABADI',
              onTap: () => _showTransferUpload(car, total),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF0284C7))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showTransferUpload(CarModel car, double total) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Upload Bukti Transfer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: const Column(
                children: [
                  Text('Rekening Tujuan:', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text('Permata Bank: 04124428500', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('an. Koperasi Karyawan Menara Makmur Abadi', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () => _processBooking(car, 'Transfer Bank'),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey.shade400), const SizedBox(height: 12), const Text('Klik untuk upload foto bukti transfer', style: TextStyle(fontSize: 12, color: Colors.grey))]),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => _processBooking(car, 'Transfer Bank'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF14A96B), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Konfirmasi & Kirim Bukti'))),
          ],
        ),
      ),
    );
  }

  void _processBooking(CarModel car, String method) {
    final authProvider = context.read<AuthProvider>();
    final double total = car.pricePerDay * (_selectedDurasi / 12);

    // Sekarang Potong Gaji Sewa Mobil tidak mengurangi Limit Belanja (Tersendiri)
    // Kita gunakan addManualTransaction agar data tetap ter-collect untuk Admin
    authProvider.addManualTransaction(
      total,
      method == 'Potong Gaji' ? 'SEWA MOBIL (POTONG GAJI)' : 'SEWA MOBIL (TRANSFER)',
      ['Sewa ${car.name} (${_selectedDurasi}j)']
    );

    Navigator.pop(context); // Tutup modal (pembayaran atau upload)
    _showSuccessDialog(car.name, method);
  }

  void _showSuccessDialog(String carName, String method) {
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
            const Text('Pesanan Terkirim!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Permintaan sewa $carName via $method telah kami terima. Admin akan melakukan verifikasi.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Tutup'))),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAdmin() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: Column(children: [
        const Text('Butuh sewa lebih dari 48 jam?', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
          label: const Text('Hubungi Bapak Agus', style: TextStyle(color: Color(0xFF1F2937))),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF25D366)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ]),
    );
  }

  String _formatNumber(int number) => number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
}
