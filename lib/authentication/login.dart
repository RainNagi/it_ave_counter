import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'repository/authentication.dart';
import '/home/home.dart';
import 'register.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authRepository = AuthRepository();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  bool _isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }
  
  Future<void> login() async {
    var data = await authRepository.login(emailController.text, passwordController.text);

    if (data["status"] == "success") {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('uname', data["uname"]);

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
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    double iconSize = screenType == MOBILE ? 50 : 70; 
    double titleSize = screenType == MOBILE ? 17 : 24;
    double textFieldSize = screenType == MOBILE ? 35 : 50;
    double textFieldFontSize = screenType == MOBILE ? 14 : 18;
    double textFieldIconSize = screenType == MOBILE ? 20 : 25;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: screenType == MOBILE ? 350 : 550,
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
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Login',
                style: GoogleFonts.poppins(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 227, 64, 55),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: textFieldSize,
                      child: TextField(
                        controller: emailController,
                        style: TextStyle(color: Colors.black, fontSize:  textFieldFontSize),
                        decoration: InputDecoration(
                          labelText: 'Email or Username',
                          labelStyle: TextStyle(color: Colors.grey, fontSize:  textFieldFontSize),
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
                          prefixIcon: Icon(LucideIcons.mail, size: textFieldIconSize),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: textFieldSize,
                      child: TextField(
                        controller: passwordController,
                        obscureText: _isObscure,
                        style: TextStyle(color: Colors.black, fontSize:  textFieldFontSize),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.grey, fontSize:  textFieldFontSize),
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
                          prefixIcon: Icon(LucideIcons.lock, size: textFieldIconSize),
                          suffixIcon: IconButton(
                            icon: Icon(_isObscure ? LucideIcons.eyeOff : LucideIcons.eye, size: textFieldIconSize),
                            onPressed: togglePasswordVisibility, 
                          ),
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
                          style: GoogleFonts.poppins(color: Colors.white , fontSize:  screenType == MOBILE ? 14 : 18),
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
                            style: GoogleFonts.poppins(color: Colors.black, fontSize:  screenType == MOBILE ? 10 : 14),
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
                              style: GoogleFonts.poppins(color: Color.fromARGB(255, 11, 129, 240), fontSize:  screenType == MOBILE ? 10 : 14),
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
