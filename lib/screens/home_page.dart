import 'package:flutter/material.dart';
import 'sewa_mobil_page.dart';
import 'pinjaman_page.dart';
import 'shop_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFF14A96B),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.normal),
              ),
              Text(
                'Budi Santoso',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            const SizedBox(height: 24),
            _buildLayanan(context),
            const SizedBox(height: 24),
            _buildPromoSpesial(),
            const SizedBox(height: 24),
            _buildTransaksiTerakhir(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF14A96B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Saldo Simpanan',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Rp 12.450.000',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'No. Anggota: 001234567',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF14A96B),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_outward, size: 18),
                  label: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.south_west, size: 18),
                  label: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayanan(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildLayananItem(
                  icon: Icons.directions_car,
                  color: Colors.blue,
                  label: 'Sewa Mobil',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SewaMobilPage()),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildLayananItem(
                  icon: Icons.volunteer_activism,
                  color: Colors.purple,
                  label: 'Pinjaman',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PinjamanPage()),
                    );
                  },
                ),
              ),
              Expanded(child: _buildLayananItem(icon: Icons.inventory_2_outlined, color: Colors.orange, label: 'Open PO')),
              Expanded(
                child: _buildLayananItem(
                  icon: Icons.shopping_cart_outlined,
                  color: Colors.green,
                  label: 'Belanja',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopPage(isStatic: false)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayananItem({required IconData icon, required Color color, required String label, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
        ],
      ),
    );
  }

  Widget _buildPromoSpesial() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sell_outlined, size: 20, color: Colors.black87),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Promo Spesial',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Lihat Semua >',
                style: TextStyle(fontSize: 14, color: const Color(0xFF14A96B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPromoCard(
            title: 'Diskon 50% Transfer',
            subtitle: 'Gratis biaya admin transfer antar bank',
            color: const Color(0xFF9B4CFF), // Purple
          ),
          const SizedBox(height: 12),
          _buildPromoCard(
            title: 'Cashback Belanja 20%',
            subtitle: 'Maksimal cashback Rp 50.000',
            color: const Color(0xFFFF5E00), // Orange
          ),
          const SizedBox(height: 12),
          _buildPromoCard(
            title: 'Bunga Simpanan 8%',
            subtitle: 'Dapatkan bunga lebih tinggi untuk simpanan berjangka',
            color: const Color(0xFF1E70FF), // Blue
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({required String title, required String subtitle, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiTerakhir() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Transaksi Terakhir',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTransaksiItem(
            icon: Icons.south_west,
            iconColor: Colors.green,
            title: 'Top Up Saldo',
            date: '01 Apr 2026',
            amount: '+Rp 500.000',
            amountColor: Colors.green,
            status: 'Berhasil',
          ),
          const SizedBox(height: 12),
          _buildTransaksiItem(
            icon: Icons.arrow_outward,
            iconColor: Colors.red,
            title: 'Transfer ke Ani',
            date: '31 Mar 2026',
            amount: '-Rp 150.000',
            amountColor: Colors.red,
            status: 'Berhasil',
          ),
          const SizedBox(height: 12),
          _buildTransaksiItem(
            icon: Icons.arrow_outward,
            iconColor: Colors.red,
            title: 'Bayar Listrik',
            date: '30 Mar 2026',
            amount: '-Rp 350.000',
            amountColor: Colors.red,
            status: 'Berhasil',
          ),
          const SizedBox(height: 12),
          _buildTransaksiItem(
            icon: Icons.south_west,
            iconColor: Colors.green,
            title: 'Bunga Simpanan',
            date: '28 Mar 2026',
            amount: '+Rp 75.000',
            amountColor: Colors.green,
            status: 'Berhasil',
          ),
        ],
      ),
    );
  }

  Widget _buildTransaksiItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String date,
    required String amount,
    required Color amountColor,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: amountColor),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
