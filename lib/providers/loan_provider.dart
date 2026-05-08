import 'package:flutter/material.dart';
import 'package:koperasi_mtm/models/loan_model.dart';
import 'package:koperasi_mtm/services/loan_service.dart';

class LoanProvider with ChangeNotifier {
  final LoanService _loanService;

  LoanProvider(this._loanService);

  List<LoanCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<LoanCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _loanService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LoanApplication?> applyLoan({
    required String categoryId,
    required double amount,
    required int tenor,
    required String purpose,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _loanService.applyLoan(
        categoryId: categoryId,
        amount: amount,
        tenor: tenor,
        purpose: purpose,
      );
      return result;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
