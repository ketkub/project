import 'package:flutter/material.dart';
import 'package:flutter_product_app/screens/login_screen.dart';
import 'package:flutter_product_app/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'restaurant_detail_screen.dart';

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
  final User user;

  const RestaurantListScreen({super.key, required this.user});

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
    try {
      final response = await http.get(
          Uri.parse('http://192.168.56.1:3000/api/restaurants'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to load restaurant data');
      }
    } catch (error) {
      print('Error fetching restaurants: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Restaurant List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: restaurants.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.75,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 5.0,
                      shadowColor: Colors.blueAccent.withOpacity(0.2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12.0)),
                              child: Image.network(
                                restaurant.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error, size: 50),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 4.0),
                            child: Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              restaurant.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
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
