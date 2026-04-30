import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../models/transaction_model.dart';
import 'detail_pinjaman_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Semua',
    'Sewa Mobil',
    'Belanja',
    'Pinjaman',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Aktivitas Saya',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryList(),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Expanded(
            child: _buildActivityList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityList() {
    final transactions = context.watch<AuthProvider>().transactions;

    // Gabungkan data statis dengan data dinamis dari provider
    final List<Map<String, dynamic>> staticActivities = [
      {
        'title': 'Sewa Toyota Avanza',
        'status': 'Sedang Berjalan',
        'statusColor': const Color(0xFF0284C7),
        'icon': Icons.directions_car_outlined,
        'date': 'Hari Ini - Besok',
        'amount': 'Rp 420.000',
        'description': 'Lepas Kunci (24 Jam)',
        'category': 1, // Sewa Mobil
      },
      {
        'title': 'Pembelian Toko',
        'status': 'Diproses',
        'statusColor': const Color(0xFFF97316),
        'icon': Icons.shopping_bag_outlined,
        'date': 'Hari Ini',
        'amount': 'Rp 85.000',
        'description': 'Minyak Goreng, Beras, Gula',
        'category': 2, // Belanja
      },
      {
        'title': 'Pengajuan Pembiayaan',
        'status': 'Verifikasi Admin',
        'statusColor': const Color(0xFF84CC16),
        'icon': Icons.account_balance_wallet_outlined,
        'date': 'Hari Ini',
        'amount': 'Rp 5.000.000',
        'description': 'Kategori: Multiguna',
        'category': 3, // Pinjaman
      },
    ];

    // Konversi TransactionModel ke format Map aktivitas
    final List<Map<String, dynamic>> dynamicActivities = transactions.map((trx) {
      IconData icon;
      Color color;
      int category;
      String title = trx.type;

      if (trx.type == 'BELANJA') {
        icon = Icons.shopping_bag_outlined;
        color = const Color(0xFFF97316);
        category = 2;
        title = 'Pembelian Toko';
      } else if (trx.type == 'SEWA_MOBIL') {
        icon = Icons.directions_car_outlined;
        color = const Color(0xFF0284C7);
        category = 1;
        title = 'Sewa Mobil';
      } else if (trx.type.contains('PINJAMAN') || trx.type.contains('PEMBIAYAAN')) {
        icon = Icons.account_balance_wallet_outlined;
        color = const Color(0xFF84CC16);
        category = 3;
      } else if (trx.type.contains('MTM')) {
        icon = Icons.receipt_long_rounded;
        color = const Color(0xFF1296C4);
        category = 2; // Masuk kategori belanja/toko
      } else {
        icon = Icons.history_edu_rounded;
        color = Colors.blueGrey;
        category = 0; // Lainnya
      }

      return {
        'title': title,
        'status': 'Selesai',
        'statusColor': color,
        'icon': icon,
        'date': DateFormat('dd MMM yyyy').format(trx.date),
        'amount': 'Rp ${trx.amount.toInt().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}',
        'description': trx.items.join(', '),
        'category': category,
      };
    }).toList();

    // Gabungkan semua
    List<Map<String, dynamic>> allActivities = [...dynamicActivities, ...staticActivities];

    List<Map<String, dynamic>> filteredActivities = allActivities;
    if (_selectedCategoryIndex != 0) {
      filteredActivities = allActivities.where((a) => a['category'] == _selectedCategoryIndex).toList();
    }

    if (filteredActivities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_late_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Tidak ada aktivitas untuk kategori ini', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildActivityCard(
            title: activity['title'],
            status: activity['status'],
            statusColor: activity['statusColor'],
            icon: activity['icon'],
            date: activity['date'],
            amount: activity['amount'],
            description: activity['description'],
            isPO: activity['isPO'] ?? false,
            progress: activity['progress'] ?? 0.0,
          ),
        );
      },
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String date,
    required String amount,
    required String description,
    bool isPO = false,
    double progress = 0.0,
  }) {
    return InkWell(
      onTap: () {
        if (title.contains('Pembiayaan')) {
          // Ambil tipe pengajuan dari deskripsi (misal: "Kategori: Multiguna")
          String tipe = 'Multiguna';
          if (description.contains(': ')) {
            tipe = description.split(': ').last;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPinjamanPage(
                title: title,
                amount: amount,
                date: date,
                tipePengajuan: tipe,
                currentStep: 1,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),
                  if (isPO) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Progress PO', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        Text('${(progress * 100).toInt()}% Terpenuhi',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF84CC16), fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: const Color(0xFFF3F4F6),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF84CC16)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      const Spacer(),
                      Text(
                        amount,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF14A96B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
