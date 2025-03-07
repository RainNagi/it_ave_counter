import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController unameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String unameError = "";
  String emailError = "";
  String passwordError = "";

  Future<void> registerUser() async {
    setState(() {
      unameError = "";
      emailError = "";
      passwordError = "";
    });

    var url = Uri.parse("http://192.168.1.239/kpi_itave/auth-handler.php");
    var response = await http.post(url, body: {
      "action": "register",
      "uname": unameController.text,
      "email": emailController.text,
      "password": passwordController.text,
    });

    try {
      var data = jsonDecode(response.body);
      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
        Navigator.pop(context); // Go back to login after successful registration
      } else {
        setState(() {
          if (data["error_field"] == "uname") {
            unameError = data["message"];
          } else if (data["error_field"] == "email") {
            emailError = data["message"];
          } else if (data["error_field"] == "password") {
            passwordError = data["message"];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to process registration.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 350,
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),

              // Username Field
              TextField(
                controller: unameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              if (unameError.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      unameError,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(height: 10),

              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              if (emailError.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      emailError,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(height: 10),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              if (passwordError.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      passwordError,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
              SizedBox(height: 20),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Already have an account? Login
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Already have an account? Login",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
