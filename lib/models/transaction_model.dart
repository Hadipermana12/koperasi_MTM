class TransactionModel {
  final String id;
  final String npk;
  final String userName;
  final double amount;
  final DateTime date;
  final String type; // 'BELANJA', 'SEWA_MOBIL', 'SIMPANAN', 'PENARIKAN'
  final List<String> items;
  final String status; // 'SELESAI', 'PENDING', 'PROSES'

  TransactionModel({
    required this.id,
    required this.npk,
    required this.userName,
    required this.amount,
    required this.date,
    required this.type,
    required this.items,
    this.status = 'SELESAI',
  });
}
