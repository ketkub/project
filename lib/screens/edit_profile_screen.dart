import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;
  }

  void _update() async {
    final username = _usernameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and email cannot be empty')),
      );
      return;
    }


    final response = await _apiService.updateProfile(
      widget.user.userId,
      username,
      email,
      password,
      _image,
    );

    if (response != null && response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      // If update succeeds, pop the current screen and return the image
      Navigator.pop(context, _image != null ? File(_image!.path) : null);
    }
  }

  Future<void> _selectImage() async {
    final pickedImage = await showDialog<XFile?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                final image = await _picker.pickImage(source: ImageSource.camera);
                Navigator.of(context).pop(image);
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                final image = await _picker.pickImage(source: ImageSource.gallery);
                Navigator.of(context).pop(image);
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    setState(() {
      _image = pickedImage; // Update the selected image
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _update,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
