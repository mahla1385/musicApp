import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/user_session.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  String get _profileKey => 'profile_image_path_${UserSession.userId}';

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_profileKey);
    if (path != null && await File(path).exists()) {
      setState(() => _profileImage = File(path));
    } else {
      setState(() => _profileImage = null);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final uniqueName = 'profile_${UserSession.userId}.png';
        final savedImage = await File(image.path).copy('${directory.path}/$uniqueName');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_profileKey, savedImage.path);

        setState(() => _profileImage = savedImage);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_profileKey);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      await prefs.remove(_profileKey);
    }
    setState(() => _profileImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final String username = UserSession.username ?? 'Unknown';
    final String email = UserSession.email ?? 'Unknown';
    final bool premium = UserSession.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? const Icon(Icons.person, size: 48) : null,
              ),
            ),
            const SizedBox(height: 12),
            if (_profileImage != null)
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                label: const Text('Remove Profile Picture', style: TextStyle(color: Colors.redAccent)),
              ),
            const SizedBox(height: 16),
            Text(
              username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 18),
            Chip(
              label: Text(premium ? 'Premium User' : 'Free User'),
              backgroundColor: premium ? Colors.cyan : Colors.grey[400],
              labelStyle: const TextStyle(color: Colors.white),
              avatar: Icon(
                premium ? Icons.star : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout'),
              onTap: () {
                UserSession.clear();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.cyan[700],
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 0) {
            if (UserSession.userId == null) {
              Navigator.pushReplacementNamed(context, '/guestHome');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else if (index == 1) {
            if (UserSession.userId == null) {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            } else {
              Navigator.pushReplacementNamed(context, '/musicshop');
            }
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}