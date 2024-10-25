import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String restaurantName;
  final String description;
  final String locationUrl;

  RestaurantDetailScreen({
    required this.imageUrl,
    required this.restaurantName,
    required this.description,
    required this.locationUrl,
  });

  @override
  _RestaurantDetailScreenState createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  List<Map<String, dynamic>> _reviews = []; // To store reviews and ratings
  double _rating = 0; // Variable to hold the rating

  void _saveReview() {
    if (_reviewController.text.isNotEmpty && _rating > 0) {
      setState(() {
        // Add new review and rating to the List
        _reviews.add({
          'review': _reviewController.text,
          'rating': _rating,
        });
        _reviewController.clear(); // Clear the TextField
        _rating = 0; // Reset the rating
      });
      print("Current reviews: $_reviews"); // Show current reviews in Console
    } else {
      // Message for when no review or rating is entered
      print("No review entered or no rating selected.");
    }
  }

  // Function to set the rating
  void _setRating(double rating) {
    setState(() {
      _rating = rating; // Update rating
    });
  }

  void _launchURL() async {
    final Uri url = Uri.parse(widget.locationUrl);
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.restaurantName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _launchURL,
              child: Text('View Location'), // เปลี่ยนข้อความที่นี่
            ),
            const SizedBox(height: 16.0),

            // TextField for writing reviews
            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Write a review',
                border: OutlineInputBorder(),
              ),
            ),

            // Star rating display
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => _setRating(index + 1), // Set rating
                );
              }),
            ),
            const SizedBox(height: 8.0),
            Text('Rating: $_rating',
                style: TextStyle(fontSize: 16)), // Show selected rating
            const SizedBox(height: 16.0),

            // Save review button
            ElevatedButton(
              onPressed: _saveReview,
              child: Text('Save Review'),
            ),
            const SizedBox(height: 16.0),

            // Header for Reviews
            Text(
              'Reviews:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),

            // Display ListView for reviews
            Container(
              height: 200, // Set height for ListView
              child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_reviews[index]['review']), // Show added review
                    subtitle: Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < _reviews[index]['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
