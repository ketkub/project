import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final User user;

  ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  void _loadProfileImage() {
    // ตรวจสอบว่าผู้ใช้มีภาพโปรไฟล์หรือไม่
    if (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isEmpty) {
      // ตรวจสอบว่าเป็น URL หรือ path
      setState(() {
        _profileImage = File(widget.user.profileImageUrl!); // เปลี่ยนเป็น NetworkImage ถ้าจำเป็น
      });
    }
  }

  void _deleteAccount(BuildContext context) async {
    final apiService = ApiService();
    final success = await apiService.deleteAccount(widget.user.userId);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete account')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.amber,
                backgroundImage: _profileImage != null 
                    ? FileImage(_profileImage!) 
                    : (widget.user.profileImageUrl != null && widget.user.profileImageUrl!.isNotEmpty 
                        ? NetworkImage(widget.user.profileImageUrl!) 
                        : null),
                child: _profileImage == null 
                    ? Text(
                        widget.user.username.isNotEmpty ? widget.user.username[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome, ${widget.user.username}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                widget.user.email,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(user: widget.user),
                    ),
                  );
                  if (result != null && result is File) {
                    setState(() {
                      _profileImage = result;
                    });
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                  backgroundColor: Colors.amber,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _deleteAccount(context),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Account'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 45),
                  backgroundColor: Colors.red,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
