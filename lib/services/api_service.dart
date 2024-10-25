import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      'https://apinodedb-7e4w.onrender.com/api/'; // URL ของ RESTful API

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Login failed with status: ${response.statusCode}');
        return {'error': 'Login failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'error': 'An error occurred during login. Please try again.'};
    }
  }

  Future<Map<String, dynamic>?> signup(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Signup failed with status: ${response.statusCode}');
        return {'error': 'Signup failed with status: ${response.statusCode}'};
      }
    } catch (e) {
      print('Signup error: $e');
      return {'error': 'An error occurred during signup. Please try again.'};
    }
  }

  Future<bool> deleteAccount(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        return true; // Account successfully deleted
      } else {
        print('Delete account failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete account error: $e');
    }
    return false; // Account deletion failed
  }

  Future<Map<String, dynamic>?> updateProfile(
      int userId, String username, String email, String password) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Update profile failed with status: ${response.statusCode}');
        return {
          'error': 'Update profile failed with status: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Update profile error: $e');
      return {
        'error':
            'An error occurred while updating the profile. Please try again.'
      };
    }
  }
}
