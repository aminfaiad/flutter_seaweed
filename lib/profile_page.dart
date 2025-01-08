import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;

  // Sample data
  final String _email = "example@email.com";
  final List<String> _listedFarms = ["Farm1", "Farm2", "Farm3"];

  @override
  void initState() {
    super.initState();
    _usernameController.text = "JohnDoe"; // Default username
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;

      if (!_isEditing) {
        // Save the updated username to backend or database
        print("Updated username: ${_usernameController.text}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: Colors.green,
            ),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(height: 20),

            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('asset/default.jpg'), // Default picture path
            ),
            SizedBox(height: 20),

            // Your Information
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Information",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Username
            TextField(
              controller: _usernameController,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Email (Non-editable)
            TextField(
              controller: TextEditingController(text: _email),
              enabled: false,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Listed Farms (Non-editable)
            TextField(
              controller: TextEditingController(
                  text: _listedFarms.join(", ")), // Join farm list into a string
              enabled: false,
              decoration: InputDecoration(
                labelText: "Listed Farms",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
