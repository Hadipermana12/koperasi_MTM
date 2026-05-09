import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressService {
  final Dio _dio = Dio();
  
  // Mengambil URL dari .env jika ada, jika tidak gunakan default Emsifa (Gratis & Tanpa API Key)
  String get _baseUrl => dotenv.env['ADDRESS_API_URL'] ?? 'https://www.emsifa.com/api-wilayah-indonesia/api';

  Future<List<Map<String, dynamic>>> getProvinsi() async {
    try {
      // Emsifa menggunakan format .json
      final response = await _dio.get('$_baseUrl/provinces.json');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching provinsi: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKabupaten(String idProvinsi) async {
    try {
      final response = await _dio.get('$_baseUrl/regencies/$idProvinsi.json');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching kabupaten: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKecamatan(String idKabupaten) async {
    try {
      final response = await _dio.get('$_baseUrl/districts/$idKabupaten.json');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching kecamatan: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKelurahan(String idKecamatan) async {
    try {
      final response = await _dio.get('$_baseUrl/villages/$idKecamatan.json');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Error fetching kelurahan: $e');
      return [];
    }
  }
}
