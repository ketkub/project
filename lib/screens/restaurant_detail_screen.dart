import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String restaurantName;
  final String description;
  final String locationUrl;

  const RestaurantDetailScreen({
    super.key,
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
  final List<Map<String, dynamic>> _reviews = [];
  double _rating = 0;

  void _saveReview() {
    if (_reviewController.text.isNotEmpty && _rating > 0) {
      setState(() {
        _reviews.add({
          'review': _reviewController.text,
          'rating': _rating,
        });
        _reviewController.clear();
        _rating = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter review and select a rating')),
      );
    }
  }

  void _setRating(double rating) {
    setState(() {
      _rating = rating;
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
        backgroundColor: Colors.amber,
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
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100);
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.restaurantName,
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _launchURL,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: const Icon(Icons.location_on),
              label: const Text('View Location'),
            ),
            const SizedBox(height: 24.0),

            TextField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Write a review',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => _setRating(index + 1),
                );
              }),
            ),
            Text(
              'Rating: $_rating',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: _saveReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Save Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24.0),

            Text(
              'Reviews:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            _reviews.isEmpty
                ? const Text('No reviews yet')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviews.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(_reviews[index]['review']),
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
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
