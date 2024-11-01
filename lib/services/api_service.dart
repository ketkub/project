import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ApiService {
  final String baseUrl = 'http://192.168.56.1:3000/api';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    return await _postRequest('/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> signup(String username, String email, String password) async {
    return await _postRequest('/users', {'username': username, 'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> _postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('Request error: $e');
      return {'error': 'An error occurred during the request. Please try again.'};
    }
  }

  Future<bool> deleteAccount(int userId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$userId'));

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Delete account failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Delete account error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> updateProfile(int userId, String username, String email, String password, XFile? image) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/users/$userId'));

    request.fields['username'] = username;
    request.fields['email'] = email;

    if (password.isNotEmpty) {
      request.fields['password'] = password;
    }

    if (image != null) {
      final mimeType = lookupMimeType(image.path)?.split('/');
      final file = await http.MultipartFile.fromPath(
        'profile_image',
        image.path,
        contentType: MediaType(mimeType![0], mimeType[1]),
      );
      request.files.add(file);
    }

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        return jsonDecode(responseData.body);
      } else {
        return _handleError(responseData);
      }
    } catch (e) {
      print('Update profile error: $e');
      return {'error': 'An error occurred while updating the profile. Please try again.'};
    }
  }

  Map<String, dynamic> _handleError(http.Response response) {
    String errorMessage = 'Request failed with status: ${response.statusCode}';
    
    try {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      errorMessage = responseBody['error'] ?? errorMessage;
    } catch (e) {
      print('Error parsing response: $e');
    }

    return {'error': errorMessage};
  }
}
