import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordPage extends StatefulWidget {
  final String username; // Pass username if needed for API authentication

  ChangePasswordPage({required this.username});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _changePassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate inputs
    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "All fields are required.";
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    try {
      // Replace with your actual API endpoint
      final Uri url = Uri.parse("https://smartseaweed.site/Real/change_password.php");
      final response = await http.post(
        url,
        body: {
          'username': widget.username, // Assuming username is passed for authentication
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        if (responseBody['status'] == 'success') {
          setState(() {
            _isLoading = false;
          });

          // Display success message and redirect
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Success"),
              content: Text("Password has been successfully changed."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmDashboardPage(
                          username: widget.username,
                          mobile_token: 'UHHYUYUHUY',
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        } else if (responseBody['status'] == 'error' &&
            responseBody['message'] == 'Old password incorrect') {
          setState(() {
            _isLoading = false;
            _errorMessage = "Old password is incorrect.";
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = responseBody['message'] ?? "An error occurred.";
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to connect to the server.";
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = "An error occurred: $error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => FarmDashboardPage(
                  username: widget.username,
                  mobile_token: "SIIIIIIIIII",
                ),
              ),
              (route) => false,
            );
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dummy Image
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[300],
                    child: Center(
                      child: Text("Image Placeholder"),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // Old Password TextField
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Old Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: Icon(Icons.visibility),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // New Password TextField
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    suffixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Confirm Password TextField
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Confirm Change Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      _isLoading ? 'Loading...' : 'CONFIRM CHANGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}