import 'package:flutter/material.dart';

class SewaMobilPage extends StatefulWidget {
  const SewaMobilPage({super.key});

  @override
  State<SewaMobilPage> createState() => _SewaMobilPageState();
}

class _SewaMobilPageState extends State<SewaMobilPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  int _durasiHari = 1;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sewa Mobil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchForm(),
            _buildCarList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextFieldLabel('Tanggal Sewa (Mulai - Selesai)'),
          _buildTextField(
            icon: Icons.calendar_today_outlined, 
            text: '${_formatDate(_startDate)} s/d ${_formatDate(_endDate)}', 
            onTap: () => _selectDateRange(context),
          ),
          const SizedBox(height: 16),
          _buildTextFieldLabel('Durasi'),
          _buildDurationCounter(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14A96B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Cari Mobil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF14A96B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _durasiHari = _endDate.difference(_startDate).inDays;
        if (_durasiHari == 0) _durasiHari = 1; // Minimal hitungan 1 hari
        _endDate = _startDate.add(Duration(days: _durasiHari)); 
      });
    }
  }

  Widget _buildTextField({required IconData icon, required String text, bool readOnly = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey.shade50 : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(fontSize: 15, color: readOnly ? Colors.black54 : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: Colors.grey.shade500),
              const SizedBox(width: 12),
              Text('$_durasiHari Hari', style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (_durasiHari > 1) {
                    setState(() {
                      _durasiHari--;
                      _endDate = _startDate.add(Duration(days: _durasiHari));
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                  child: const Icon(Icons.remove, size: 20, color: Colors.black87),
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  setState(() {
                    _durasiHari++;
                    _endDate = _startDate.add(Duration(days: _durasiHari));
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Color(0xFF14A96B), shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 20, color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


  Widget _buildCarList(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mobil Tersedia (5)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _buildCarCard(
            context: context,
            name: 'Toyota Avanza',
            imagePath: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=400',
            basePrice: 350000,
            seats: '7 Kursi',
            transmission: 'Manual',
            isAvailable: true,
          ),
          const SizedBox(height: 16),
          _buildCarCard(
            context: context,
            name: 'Honda Civic',
            imagePath: 'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&q=80&w=400',
            basePrice: 450000,
            seats: '5 Kursi',
            transmission: 'Matic',
            isAvailable: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCarCard({
    required BuildContext context,
    required String name,
    required String imagePath,
    required int basePrice,
    required String seats,
    required String transmission,
    required bool isAvailable,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          if (isAvailable) {
            _showCarDetails(context, name, imagePath, basePrice, seats, transmission);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maaf, mobil ini sedang tidak tersedia.')),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagePath,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatCurrency(basePrice),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
                        ),
                        const Text(
                          'per hari',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(seats, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    Icon(Icons.settings_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(transmission, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14A96B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'Detail & Pesan',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF14A96B)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    ),
  );
  }

  void _showCarDetails(BuildContext context, String name, String imagePath, int basePrice, String seats, String transmission) {
    int totalPembayaran = basePrice * _durasiHari;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detail Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imagePath, width: double.infinity, height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.people_alt_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(seats, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(width: 16),
                  Icon(Icons.settings_outlined, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(transmission, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.grey),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Harga Sewa per hari', style: TextStyle(fontSize: 14)),
                  Text(_formatCurrency(basePrice), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Durasi', style: TextStyle(fontSize: 14)),
                  Text('$_durasiHari Hari', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.grey),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(_formatCurrency(totalPembayaran), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF14A96B))),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Berhasil memesan $name!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14A96B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lanjutkan Pemesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
