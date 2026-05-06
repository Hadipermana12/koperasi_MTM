import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  
  UserModel? _user;
  bool _isLoading = false;
  final List<TransactionModel> _transactions = [];
  Map<String, Map<String, dynamic>> _registeredUsers = {};

  AuthProvider() {
    _loadData();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  List<TransactionModel> get transactions => [..._transactions];
  Map<String, Map<String, dynamic>> get allRegisteredUsers => _registeredUsers;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Users from Local (Legacy/Cache)
    final usersJson = prefs.getString('registered_users');
    if (usersJson != null) {
      _registeredUsers = Map<String, Map<String, dynamic>>.from(json.decode(usersJson));
    }

    // Check for existing token
    final token = await _apiService.getToken();
    if (token != null) {
      try {
        final response = await _apiService.getProfile();
        if (response.statusCode == 200) {
          final userData = response.data['data'];
          _user = UserModel(
            npk: userData['npk'],
            name: userData['name'],
            limitBelanja: 1500000, // Still hardcoded for now or get from API if available
            terpakai: 0,
            bankName: userData['bankInfo']?['bankName'],
            accountNumber: userData['bankInfo']?['accountNumber'],
          );
        }
      } catch (e) {
        // Token might be invalid
        await _apiService.clearTokens();
      }
    }

    // Load Transactions
    final trxJson = prefs.getString('transactions_history');
    if (trxJson != null) {
      final List<dynamic> decoded = json.decode(trxJson);
      _transactions.clear();
      _transactions.addAll(decoded.map((item) => TransactionModel(
        id: item['id'],
        npk: item['npk'],
        userName: item['userName'],
        amount: item['amount'],
        date: DateTime.parse(item['date']),
        type: item['type'],
        items: List<String>.from(item['items']),
        status: item['status'] ?? 'SELESAI',
      )));
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('registered_users', json.encode(_registeredUsers));

    // Simpan history transaksi
    final List<Map<String, dynamic>> trxList = _transactions.map((t) => {
      'id': t.id,
      'npk': t.npk,
      'userName': t.userName,
      'amount': t.amount,
      'date': t.date.toIso8601String(),
      'type': t.type,
      'items': t.items,
      'status': t.status,
    }).toList();
    await prefs.setString('transactions_history', json.encode(trxList));
  }

  Future<bool> login(String npk, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(npk, password);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final userMap = data['user'];

        if (userMap['isActive'] == false || userMap['isActive'] == 0 || userMap['isActive'] == "0" || userMap['isActive'] == "false") {
            _isLoading = false;
            notifyListeners();
            throw Exception("Akun anda belum diverifikasi oleh admin");
        }

        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        await _apiService.saveTokens(accessToken, refreshToken);

        _user = UserModel(
          npk: userMap['npk'],
          name: userMap['name'],
          limitBelanja: 1500000,
          terpakai: 0,
          bankName: 'BCA (Connected)',
          accountNumber: '-',
          simpananWajib: 100000,
          simpananSukarela: 500000,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      String errorMsg = "NPK atau Password salah.";
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data['message'] != null) {
            errorMsg = data['message'];
          } else if (data['error'] != null) {
            errorMsg = data['error'];
          }
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (e.toString().contains("Akun anda belum diverifikasi")) {
          rethrow;
      }
      debugPrint('Login error: $e');
    }

    // Fallback to simulation for development if needed, but the objective is real integration
    if (npk == '123' && password == 'admin') {
      _user = UserModel(
        npk: npk,
        name: 'Putri Permata (Simulasi)',
        limitBelanja: 1500000,
        terpakai: 0,
        bankName: 'BCA',
        accountNumber: '8830123456',
        simpananWajib: 2500000,
        simpananSukarela: 1500000,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register(userData);
      if (response.statusCode == 201) {
        // Also save locally for legacy support if needed
        final String npk = userData['npk'];
        _registeredUsers[npk] = userData;
        await _saveData();

        _isLoading = false;
        notifyListeners();
        return;
      } else {
        throw Exception("Gagal mendaftar. Silakan coba lagi.");
      }
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      
      String errorMsg = "Terjadi kesalahan jaringan atau server.";
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data['message'] != null) {
            errorMsg = data['message'];
          } else if (data['error'] != null) {
            errorMsg = data['error'];
          }
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Terjadi kesalahan tidak terduga.");
    }
  }

  String generateRegistrationMessage(String npk, String name) {
    return "*PENDAFTARAN ANGGOTA BARU KMMA ONE*\n\n"
        "Halo Admin, saya ingin mendaftar mandiri:\n"
        "Nama: $name\n"
        "NPK: $npk\n"
        "Status: Menunggu Approval\n\n"
        "Mohon bantuannya untuk verifikasi akun saya. Terima kasih.";
  }

  void logout() async {
    _user = null;
    await _apiService.clearTokens();
    notifyListeners();
  }

  void updateBankInfo(String bankName, String accountNumber) {
    if (_user != null) {
      _user = UserModel(
        npk: _user!.npk,
        name: _user!.name,
        limitBelanja: _user!.limitBelanja,
        terpakai: _user!.terpakai,
        bankName: bankName,
        accountNumber: accountNumber,
        simpananWajib: _user!.simpananWajib,
        simpananSukarela: _user!.simpananSukarela,
      );
      notifyListeners();
    }
  }

  void updateProfile(String name, String npk) {
    if (_user != null) {
      _user = UserModel(
        npk: npk,
        name: name,
        limitBelanja: _user!.limitBelanja,
        terpakai: _user!.terpakai,
        bankName: _user!.bankName,
        accountNumber: _user!.accountNumber,
        simpananWajib: _user!.simpananWajib,
        simpananSukarela: _user!.simpananSukarela,
      );
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String oldPass, String newPass) async {
    // Simulasi ganti password
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  bool purchase(double amount, {List<String> items = const [], String type = 'BELANJA'}) {
    if (_user != null && _user!.sisaLimit >= amount) {
      // Kurangi Limit
      _user = UserModel(
        npk: _user!.npk,
        name: _user!.name,
        limitBelanja: _user!.limitBelanja,
        terpakai: _user!.terpakai + amount,
        bankName: _user!.bankName,
        accountNumber: _user!.accountNumber,
        simpananWajib: _user!.simpananWajib,
        simpananSukarela: _user!.simpananSukarela,
      );

      // Catat Transaksi
      final transaction = TransactionModel(
        id: 'TRX-${DateTime.now().millisecondsSinceEpoch}',
        npk: _user!.npk,
        userName: _user!.name,
        amount: amount,
        date: DateTime.now(),
        type: type,
        items: items,
      );
      _transactions.insert(0, transaction); // Tambahkan ke daftar riwayat di paling atas

      _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }

  // Mencatat transaksi tanpa memotong limit (untuk pembayaran cash/transfer) - Untuk kebutuhan "Collect Data"
  void addManualTransaction(double amount, String type, List<String> items) {
    final transaction = TransactionModel(
      id: 'TRX-M-${DateTime.now().millisecondsSinceEpoch}',
      npk: _user?.npk ?? 'GUEST',
      userName: _user?.name ?? 'Guest',
      amount: amount,
      date: DateTime.now(),
      type: type,
      items: items,
    );
    _transactions.insert(0, transaction);
    _saveData();
    notifyListeners();
  }

  void withdrawSukarela(double amount) {
    if (_user != null && (_user!.simpananSukarela ?? 0) >= amount) {
      // JANGAN kurangi saldo dulu, tunggu approval admin (simulasi)

      // Tambahkan ke riwayat sebagai PENDING
      final transaction = TransactionModel(
        id: 'WD-${DateTime.now().millisecondsSinceEpoch}',
        npk: _user!.npk,
        userName: _user!.name,
        amount: amount,
        date: DateTime.now(),
        type: 'PENARIKAN SUKARELA',
        items: ['Pencairan Simpanan Sukarela'],
        status: 'PENDING',
      );
      _transactions.insert(0, transaction);

      _saveData();
      notifyListeners();
    }
  }
}
