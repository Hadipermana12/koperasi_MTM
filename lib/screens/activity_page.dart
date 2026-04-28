import 'package:flutter/material.dart';

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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildActivityCard(
          title: 'Sewa Avanza Veloz',
          status: 'Berjalan',
          statusColor: const Color(0xFF0284C7),
          icon: Icons.directions_car_outlined,
          date: '6 Apr - 8 Apr',
          amount: 'Rp 600.000',
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          title: 'Minyak Goreng 2L',
          status: 'Menunggu Kuota PO',
          statusColor: const Color(0xFFF97316),
          icon: Icons.shopping_bag_outlined,
          date: '5 Apr 2026',
          amount: 'Rp 35.000',
          isPO: true,
          progress: 0.65,
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          title: 'Pinjaman Tunai',
          status: 'Lunas',
          statusColor: const Color(0xFF84CC16),
          icon: Icons.account_balance_wallet_outlined,
          date: 'Januari 2026',
          amount: 'Rp 5.000.000',
        ),
        const SizedBox(height: 16),
        _buildActivityCard(
          title: 'Sewa Innova Zenix',
          status: 'Selesai',
          statusColor: const Color(0xFF9CA3AF),
          icon: Icons.directions_car_outlined,
          date: '1 Mar - 2 Mar',
          amount: 'Rp 850.000',
        ),
      ],
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String status,
    required Color statusColor,
    required IconData icon,
    required String date,
    required String amount,
    bool isPO = false,
    double progress = 0.0,
  }) {
    return Container(
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
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0284C7), size: 28),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
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
                    Text(date, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    const Spacer(),
                    Text(
                      amount,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
