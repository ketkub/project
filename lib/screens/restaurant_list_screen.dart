import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'restaurant_detail_screen.dart'; // นำเข้าไฟล์รายละเอียดร้านอาหาร

class Restaurant {
  final String imageUrl;
  final String name;
  final String description;
  final String locationUrl;

  Restaurant({
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.locationUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      imageUrl: json['coverimage'],
      name: json['name'],
      description: json['description'],
      locationUrl: json['location'],
    );
  }
}

class RestaurantListScreen extends StatefulWidget {
  @override
  _RestaurantListScreenState createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  List<Restaurant> restaurants = [];

  @override
  void initState() {
    super.initState();
    fetchRestaurants();
  }

  Future<void> fetchRestaurants() async {
    final response = await http
        .get(Uri.parse('https://apinodedb-7e4w.onrender.com/api/restaurants'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
      });
    } else {
      print('Failed to load restaurant data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // จำนวนคอลัมน์
            crossAxisSpacing: 8.0, // ระยะห่างระหว่างคอลัมน์
            mainAxisSpacing: 8.0, // ระยะห่างระหว่างแถว
            childAspectRatio: 0.75, // อัตราส่วนของขนาดของแต่ละบัตร
          ),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailScreen(
                      imageUrl: restaurant.imageUrl,
                      restaurantName: restaurant.name,
                      description: restaurant.description,
                      locationUrl: restaurant.locationUrl,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4.0, // เพิ่มความลึกให้กับการ์ด
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // มุมโค้งของการ์ด
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // ใช้ Expanded เพื่อให้การ์ดมีขนาดที่ยืดหยุ่น
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(8.0)),
                        child: Image.network(
                          restaurant.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 50);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        restaurant.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        restaurant.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
