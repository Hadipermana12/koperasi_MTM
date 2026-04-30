import 'package:flutter/material.dart';

class DetailPinjamanPage extends StatelessWidget {
  final String title;
  final String amount;
  final String date;
  final String tipePengajuan;
  final int currentStep; // 1: HRD, 2: Kredit, 3: Konfirmasi, 4: Kontrak, 5: Selesai

  const DetailPinjamanPage({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    this.tipePengajuan = 'MULTIGUNA',
    this.currentStep = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail Pinjaman', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Stepper Progress
            _buildStepper(),
            const SizedBox(height: 24),
            // Ringkasan Pengajuan Card
            _buildSummaryCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = [
      'Approval Admin\n(Bapak Agus)',
      'Approval Ketua\n(Bapak Arif)',
      'Konfirmasi\nAnggota',
      'Tanda Tangan\nKontrak',
      'Selesai',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          int stepNum = index + 1;
          bool isDone = stepNum < currentStep;
          bool isActive = stepNum == currentStep;
          bool isUpcoming = stepNum > currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Line Left
                    Expanded(child: Container(height: 2, color: index == 0 ? Colors.transparent : (isDone || isActive ? const Color(0xFF0284C7) : Colors.grey.shade300))),
                    // Circle
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isActive || isDone ? const Color(0xFF0284C7) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive || isDone ? const Color(0xFF0284C7) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isDone
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : Text(
                              '$stepNum',
                              style: TextStyle(
                                color: isActive || isDone ? Colors.white : Colors.grey.shade400,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                    // Line Right
                    Expanded(child: Container(height: 2, color: index == steps.length - 1 ? Colors.transparent : (isDone ? const Color(0xFF0284C7) : Colors.grey.shade300))),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? const Color(0xFF0284C7) : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24), // Warna kuning sesuai referensi
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'Ringkasan Pengajuan',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildDetailRow('Tanggal Pengajuan', date),
                  _buildDetailRow('Tipe Pengajuan', tipePengajuan.toUpperCase()),
                  _buildDetailRow('Jumlah Pengajuan', amount),
                  _buildDetailRow('Tenor', '12 Bulan'),
                  _buildDetailRow('Angsuran/Bulan', 'Rp 450.000'),
                  _buildDetailRow('Dana Diterima', amount),
                  const SizedBox(height: 30),
                  Text(
                    _getStatusMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827))),
        ],
      ),
    );
  }

  String _getStatusMessage() {
    switch (currentStep) {
      case 1: return 'Pengajuan pinjaman sedang ditinjau oleh Bapak Agus (Admin)';
      case 2: return 'Pengajuan pinjaman sedang ditinjau oleh Bapak Arif (Ketua)';
      case 3: return 'Menunggu konfirmasi keanggotaan dari Anda';
      case 4: return 'Menunggu penandatanganan kontrak digital';
      case 5: return 'Pinjaman telah cair ke nomor rekening Anda';
      default: return '';
    }
  }
}
