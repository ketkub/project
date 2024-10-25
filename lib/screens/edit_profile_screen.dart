import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
// TODO: implement initState
    super.initState();
    _usernameController.text = widget.user['username'];
    _emailController.text = widget.user['email'];
    _passwordController.text = widget.user['password'];
  }

  void _update() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final userId = widget.user['userId'];
    final response =
        await _apiService.updateProfile(userId, username, email, password);
    if (response != null) {
// Navigate to Login Screen

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
// Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update Profile Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _update, child: Text('Update')),
          ],
        ),
      ),
    );
  }
}
