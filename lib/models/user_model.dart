class UserModel {
  final String npk;
  final String name;
  final double limitBelanja;
  final double terpakai;
  final String? bankName;
  final String? accountNumber;
  final double simpananWajib;
  final double simpananSukarela;

  UserModel({
    required this.npk,
    required this.name,
    required this.limitBelanja,
    required this.terpakai,
    this.bankName,
    this.accountNumber,
    this.simpananWajib = 0,
    this.simpananSukarela = 0,
  });

  double get sisaLimit => limitBelanja - terpakai;
  double get totalSimpanan => simpananWajib + simpananSukarela;
}
