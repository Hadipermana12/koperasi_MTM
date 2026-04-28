import 'package:flutter/material.dart';

class SewaMobilPage extends StatefulWidget {
  const SewaMobilPage({super.key});

  @override
  State<SewaMobilPage> createState() => _SewaMobilPageState();
}

class _SewaMobilPageState extends State<SewaMobilPage> {
  DateTime? _selectedDate;
  int _selectedDurasi = 12; // 12 atau 24
  String _selectedTipe = 'Lepas Kunci'; // 'Lepas Kunci' atau 'Dengan Sopir'

  String _formatDate(DateTime date) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1296C4)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sewa Mobil',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
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
            _buildSearchForm(context),
            _buildCarList(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── FORM PENCARIAN ─────────────────────────────────────────────────────────
  Widget _buildSearchForm(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal Mulai
          const Text(
            'Tanggal Mulai',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null ? 'Pilih tanggal' : _formatDate(_selectedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null ? Colors.grey.shade400 : Colors.black87,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_outlined, size: 20, color: Colors.blue.shade400),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Durasi Sewa
          const Text(
            'Durasi Sewa',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDurasiChip(12, '12 Jam'),
              const SizedBox(width: 10),
              _buildDurasiChip(24, '24 Jam\n(Maksimal)'),
            ],
          ),

          const SizedBox(height: 16),

          // Tipe Sewa
          const Text(
            'Tipe Sewa',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTipeChip('Lepas Kunci', '(Tanpa Sopir)'),
              const SizedBox(width: 10),
              _buildTipeChip('Dengan Sopir', ''),
            ],
          ),

          const SizedBox(height: 20),

          // Tombol Cari Mobil
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1296C4),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cari Mobil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurasiChip(int jam, String label) {
    final isSelected = _selectedDurasi == jam;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDurasi = jam),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1296C4) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF1296C4) : Colors.grey.shade300,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black54,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipeChip(String tipe, String sub) {
    final isSelected = _selectedTipe == tipe;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTipe = tipe),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F7F0) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF14A96B) : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tipe,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF14A96B) : Colors.black54,
                ),
              ),
              if (sub.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? const Color(0xFF14A96B) : Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── DAFTAR MOBIL ───────────────────────────────────────────────────────────
  Widget _buildCarList(BuildContext context) {
    final cars = [
      _CarData(
        name: 'Toyota Avanza',
        imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=400',
        price: 300000,
        seats: '7 Kursi',
        transmission: 'Manual',
      ),
      _CarData(
        name: 'Honda Brio',
        imageUrl: 'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?auto=format&fit=crop&q=80&w=400',
        price: 250000,
        seats: '5 Kursi',
        transmission: 'Automatic',
      ),
      _CarData(
        name: 'Daihatsu Xenia',
        imageUrl: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&q=80&w=400',
        price: 280000,
        seats: '7 Kursi',
        transmission: 'Manual',
      ),
      _CarData(
        name: 'Mitsubishi Xpander',
        imageUrl: 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&q=80&w=400',
        price: 350000,
        seats: '7 Kursi',
        transmission: 'Automatic',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mobil Tersedia',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...cars.map((car) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCarCard(context, car),
              )),
        ],
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, _CarData car) {
    final priceLabel = '${_formatCurrency(car.price)}\n/ ${_selectedDurasi} jam';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Baris atas: foto + info ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto mobil
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    car.imageUrl,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.directions_car, color: Colors.grey, size: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info mobil
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              car.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Harga
                          RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: 'Rp ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1296C4),
                                  ),
                                ),
                                TextSpan(
                                  text: _formatNumber(car.price),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1296C4),
                                  ),
                                ),
                                TextSpan(
                                  text: '\n/ $_selectedDurasi jam',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(car.seats, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(width: 12),
                          Icon(Icons.settings_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(car.transmission, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Tombol Detail & Pesan ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCarDetails(context, car),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1296C4),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Detail & Pesan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM SHEET DETAIL ────────────────────────────────────────────────────
  void _showCarDetails(BuildContext context, _CarData car) {
    final total = car.price;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Detail Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Foto
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                car.imageUrl,
                width: double.infinity,
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 170,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.directions_car, size: 60, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(car.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.people_alt_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(car.seats, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(width: 14),
                Icon(Icons.settings_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(car.transmission, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            _detailRow('Durasi Sewa', '$_selectedDurasi Jam'),
            const SizedBox(height: 8),
            _detailRow('Tipe Sewa', _selectedTipe),
            const SizedBox(height: 8),
            _detailRow(
              'Tanggal',
              _selectedDate == null ? '-' : _formatDate(_selectedDate!),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text(
                  _formatCurrency(total),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1296C4)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Berhasil memesan ${car.name}!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1296C4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Lanjutkan Pemesanan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── HELPER ─────────────────────────────────────────────────────────────────
  String _formatCurrency(int amount) {
    return 'Rp ${_formatNumber(amount)}';
  }

  String _formatNumber(int amount) {
    return amount
        .toString()
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]}.');
  }
}

// ── MODEL DATA ─────────────────────────────────────────────────────────────────
class _CarData {
  final String name;
  final String imageUrl;
  final int price;
  final String seats;
  final String transmission;

  const _CarData({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.seats,
    required this.transmission,
  });
}
