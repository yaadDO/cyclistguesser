import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/rider.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.18.2:5000';

  Future<Rider> fetchRandomRider() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/random-rider'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Rider.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load rider: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchRandomRider: $e');
      throw e;
    }
  }

}

