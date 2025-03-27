import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:convert';
import 'register.dart';
import 'home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  bool _isObscure = true;
  String ip = dotenv.get('IP_ADDRESS');

  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }


  
  Future<void> login() async {
    var url = Uri.parse("http://$ip/kpi_itave/auth-handler.php");
    var response = await http.post(url, body: {
      "action": "login",
      "email": emailController.text,
      "password": passwordController.text,
    });

    print(url);
    var data = jsonDecode(response.body);
    
    if (data["status"] == "success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uname', data["uname"]);

      setState(() {
        errorMessage = "";
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
      );
    } else {
      setState(() {
        errorMessage = data["message"] ?? "Login Failed!";
      });
    }
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 550,
          padding: EdgeInsets.all(16.0),
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
              ClipOval(
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Login',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 227, 64, 55),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Email or Username',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 11, 129, 240)),
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color.fromARGB(255, 11, 129, 240), width: 2)
                        ),
                        prefixIcon: Icon(LucideIcons.mail),
                      ),
                      
                    ),

                    SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 11, 129, 240)),
                          border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color.fromARGB(255, 11, 129, 240), width: 2)
                        ),
                        prefixIcon: Icon(LucideIcons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? LucideIcons.eyeOff : LucideIcons.eye),
                          onPressed: togglePasswordVisibility, 
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 227, 64, 55),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don’t have an account?",
                            style: GoogleFonts.poppins(color: Colors.black),
                          ),
                          SizedBox(width: 5,),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Text(
                              "Sign up",
                              style: GoogleFonts.poppins(color: Color.fromARGB(255, 11, 129, 240)),
                            )
                          ),
                        ]
                      ),
                    ),
                  ]
                ),
              ),
              
            ],
            
          ),
        ),
      ),
    );
  }
}
