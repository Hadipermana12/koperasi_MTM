import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AddressService {
  final Dio _dio = Dio();
  
  String get _baseUrl => dotenv.env['ADDRESS_API_URL'] ?? 'https://api.binderbyte.com/wilayah';
  String get _apiKey => dotenv.env['ADDRESS_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> getProvinsi() async {
    try {
      final response = await _dio.get('$_baseUrl/provinsi', queryParameters: {
        'api_key': _apiKey,
      });
      if (response.data['code'] == "200") {
        return List<Map<String, dynamic>>.from(response.data['value']);
      }
      return [];
    } catch (e) {
      print('Error fetching provinsi: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKabupaten(String idProvinsi) async {
    try {
      final response = await _dio.get('$_baseUrl/kabupaten', queryParameters: {
        'api_key': _apiKey,
        'id_provinsi': idProvinsi,
      });
      if (response.data['code'] == "200") {
        return List<Map<String, dynamic>>.from(response.data['value']);
      }
      return [];
    } catch (e) {
      print('Error fetching kabupaten: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKecamatan(String idKabupaten) async {
    try {
      final response = await _dio.get('$_baseUrl/kecamatan', queryParameters: {
        'api_key': _apiKey,
        'id_kabupaten': idKabupaten,
      });
      if (response.data['code'] == "200") {
        return List<Map<String, dynamic>>.from(response.data['value']);
      }
      return [];
    } catch (e) {
      print('Error fetching kecamatan: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getKelurahan(String idKecamatan) async {
    try {
      final response = await _dio.get('$_baseUrl/kelurahan', queryParameters: {
        'api_key': _apiKey,
        'id_kecamatan': idKecamatan,
      });
      if (response.data['code'] == "200") {
        return List<Map<String, dynamic>>.from(response.data['value']);
      }
      return [];
    } catch (e) {
      print('Error fetching kelurahan: $e');
      return [];
    }
  }
}
