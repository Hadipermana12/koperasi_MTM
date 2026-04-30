import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SimpananPage extends StatefulWidget {
  const SimpananPage({super.key});

  @override
  State<SimpananPage> createState() => _SimpananPageState();
}

class _SimpananPageState extends State<SimpananPage> {
  final _amountController = TextEditingController();

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String _getTodayDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final transactions = authProvider.transactions.where((t) => t.type.contains('SIMPANAN') || t.type.contains('PENARIKAN')).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Simpanan Anggota', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1296C4),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBalanceCard('Simpanan Wajib', user?.simpananWajib ?? 0, Icons.lock_clock_outlined, Colors.blueGrey),
            const SizedBox(height: 16),
            _buildBalanceCard('Simpanan Sukarela', user?.simpananSukarela ?? 0, Icons.volunteer_activism_outlined, const Color(0xFF14A96B), showWithdraw: true),
            const SizedBox(height: 32),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Simpanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            ),
            const SizedBox(height: 16),
            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.history_rounded, color: Colors.grey, size: 48),
                      SizedBox(height: 12),
                      Text('Belum ada riwayat simpanan', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            else
              ...transactions.map((t) => _buildHistoryItem(
                    t.type,
                    '${t.date.day} ${_getMonthName(t.date.month)} ${t.date.year}',
                    '${t.type.contains('PENARIKAN') ? '-' : '+'} ${_formatCurrency(t.amount)}',
                    t.type.contains('PENARIKAN') ? Colors.red : Colors.green,
                    status: t.type.contains('PENARIKAN') ? 'Review' : 'Selesai',
                  )),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color, {bool showWithdraw = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_formatCurrency(amount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
          if (showWithdraw) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: amount > 0 ? () => _showWithdrawDialog() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14A96B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Cairkan Simpanan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ajukan Pencairan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Simpanan Sukarela', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Nominal Pencairan',
                hintText: 'Rp 0',
                prefixIcon: const Icon(Icons.payments_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1296C4), width: 2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Alur Pencairan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _buildStep(Icons.send_rounded, 'Ajukan', 'Diajukan pada ${_getTodayDate()}', true, isActive: true),
            _buildStep(Icons.rate_review_rounded, 'Review', 'Diverifikasi oleh Admin (1-2 hari kerja)', true, isActive: false),
            _buildStep(Icons.account_balance_rounded, 'Transfer', 'Dana dikirim ke rekening terdaftar', false, isActive: false),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount <= 0) return;

                  final user = context.read<AuthProvider>().user;
                  if (amount > (user?.simpananSukarela ?? 0)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saldo tidak mencukupi')));
                    return;
                  }

                  context.read<AuthProvider>().withdrawSukarela(amount);
                  Navigator.pop(context);
                  _showSuccessRequest();
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1296C4), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Kirim Pengajuan Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String title, String desc, bool hasLine, {bool isActive = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF1296C4) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey),
            ),
            if (hasLine) Container(width: 2, height: 25, color: isActive ? const Color(0xFF1296C4).withOpacity(0.3) : Colors.grey.shade200),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? const Color(0xFF1296C4) : Colors.grey)),
              Text(desc, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  void _showSuccessRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF14A96B), size: 80),
            const SizedBox(height: 20),
            const Text('Pengajuan Berhasil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Pengajuan pencairan Anda pada ${_getTodayDate()} telah diterima. Tim Admin akan mereview permohonan Anda segera.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1296C4)),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String amount, Color color, {String? status}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  if (status != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'Review' ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: status == 'Review' ? Colors.orange : Colors.green),
                      ),
                    ),
                  ]
                ],
              )
            ]
          ),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
