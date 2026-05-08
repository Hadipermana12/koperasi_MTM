class LoanCategory {
  final String id;
  final String code;
  final String name;
  final double maxAmount;
  final int maxTenor;
  final double interestRate;

  LoanCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.maxAmount,
    required this.maxTenor,
    required this.interestRate,
  });

  factory LoanCategory.fromJson(Map<String, dynamic> json) {
    return LoanCategory(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      // Gunakan num? agar aman jika null, lalu konversi ke double
      maxAmount: (json['maxAmount'] as num? ?? 0.0).toDouble(),
      maxTenor: (json['maxTenor'] as num? ?? 0).toInt(),
      interestRate: (json['interestRate'] as num? ?? 0.0).toDouble(),
    );
  }
}

class LoanApplication {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final double totalPayment;
  final int tenor;
  final String purpose;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  LoanApplication({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.totalPayment,
    required this.tenor,
    required this.purpose,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory LoanApplication.fromJson(Map<String, dynamic> json) {
    return LoanApplication(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      totalPayment: (json['totalPayment'] as num? ?? 0.0).toDouble(),
      tenor: (json['tenor'] as num? ?? 0).toInt(),
      purpose: json['purpose']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
