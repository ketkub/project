import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProductService {
  // URL ของ RESTful API
  final String baseUrl = 'https://apinodedb-7e4w.onrender.com/api';
  // URL ของรูปภาพ
  final String imageUrl = 'https://apinodedb-7e4w.onrender.com/images';

  // เพิ่มข้อมูลสินค้าที่ใหม่
  Future<Map<String, dynamic>?> createProduct(
      File imageFile, String proname, double price) async {
    // ตรวจสอบว่าไฟล์รูปภาพมีอยู่จริงหรือไม่
    if (!imageFile.existsSync()) {
      throw Exception('ไฟล์รูปภาพไม่พบ');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/products'),
    );

    // เพิ่มฟิลด์ข้อมูลที่ส่งไปกับการร้องขอ
    request.fields.addAll({
      'proname': proname,
      'price': price.toString(),
    });

    // เพิ่มไฟล์รูปภาพไปในการร้องขอ
    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        final String responseBody = await response.stream.bytesToString();
        throw Exception(
            'เกิดข้อผิดพลาด: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  // ดึงข้อมูลสินค้าทั้งหมด
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final String responseBody = response.body;
        throw Exception(
            'ไม่สามารถโหลดข้อมูลสินค้าที่ได้: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการดึงข้อมูลสินค้าที่ได้: $e');
    }
  }

  // แก้ไขข้อมูลสินค้าด้วยการอัปเดต
  Future<Map<String, dynamic>?> updateProduct(
      int proId, File? imageFile, String proname, double price) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/products/$proId'),
    );

    // เพิ่มฟิลด์ข้อมูลที่ส่งไปกับการร้องขอ
    request.fields.addAll({
      'proname': proname,
      'price': price.toString(),
    });

    // เพิ่มไฟล์รูปภาพไปในการร้องขอถ้ามี
    if (imageFile != null && imageFile.existsSync()) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        return jsonDecode(await response.stream.bytesToString());
      } else {
        final String responseBody = await response.stream.bytesToString();
        throw Exception(
            'เกิดข้อผิดพลาด: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  // ดึงข้อมูลสินค้าตาม ID
  Future<bool> deleteProduct(int proId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/products/$proId'));

      if (response.statusCode == 200) {
        return true;
      } else {
        final String responseBody = response.body;
        throw Exception(
            'เกิดข้อผิดพลาดในการลบสินค้า: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการลบสินค้า: $e');
    }
  }
}
