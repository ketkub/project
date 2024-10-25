import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  final ApiService _apiService = ApiService();

  ProfileScreen({required this.user});

  void _deleteAccount(BuildContext context) async {
    final success = await _apiService.deleteAccount(user['userId']);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome, ${user['username']}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: user)),
                  );
                },
                child: Text('Edit Profile'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _deleteAccount(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Red color for the delete button
                ),
                child: Text('Delete Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
