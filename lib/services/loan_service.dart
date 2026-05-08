import 'package:dio/dio.dart';
import 'package:koperasi_mtm/models/loan_model.dart';
import 'package:koperasi_mtm/services/api_service.dart';

class LoanService {
  final ApiService _apiService;

  LoanService(this._apiService);

  Future<List<LoanCategory>> getCategories() async {
    try {
      final response = await _apiService.get('/loans/categories');
      final dynamic responseData = response.data;

      if (responseData is Map && responseData['status'] == 'error') {
        throw Exception(responseData['message'] ?? 'Gagal memuat kategori');
      }

      if (response.statusCode == 200) {
        List<dynamic> dataList = [];
        if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'];
        } else if (responseData is List) {
          dataList = responseData;
        }
        return dataList.map((json) => LoanCategory.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat kategori (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<LoanApplication> applyLoan({
    required String categoryId,
    required double amount,
    required int tenor,
    required String purpose,
  }) async {
    try {
      final response = await _apiService.post(
        '/loans/apply',
        data: {
          'categoryId': categoryId,
          'amount': amount,
          'tenor': tenor,
          'purpose': purpose,
        },
      );

      final dynamic responseData = response.data;

      if (responseData is Map && responseData['status'] == 'error') {
        throw Exception(responseData['message'] ?? 'Gagal mengajukan pinjaman');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LoanApplication.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Gagal mengajukan pinjaman');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final msg = e.response?.data['message'] ?? 'Gagal mengajukan pinjaman';
        throw Exception(msg);
      }
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
