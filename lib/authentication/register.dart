import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'repository/authentication.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final authRepository = AuthRepository();
  final TextEditingController unameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String unameError = "";
  String emailError = "";
  String passwordError = "";
  bool _isObscure = true;

  void togglePasswordVisibility() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> registerUser() async {
    setState(() {
      unameError = "";
      emailError = "";
      passwordError = "";
    });

    var data = await authRepository.registerUser(
      unameController.text,
      emailController.text,
      passwordController.text,
    );

    if (data["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"])),
      );
      Navigator.pop(context);
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
        child: SingleChildScrollView(
          child: Container(
            width: screenType == MOBILE ? 350 : 550,
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
                ClipOval(
                  child: Image.asset(
                    'assets/image/logo.jpg',
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 227, 64, 55),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: textFieldSize,
                        child: TextField(
                          controller: unameController,
                          style: TextStyle(color: Colors.black, fontSize:  textFieldFontSize),
                          decoration: InputDecoration(
                            labelText: "Username",
                            labelStyle: TextStyle(color: Colors.grey, fontSize:  textFieldFontSize ),
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
                            prefixIcon: Icon(LucideIcons.user, size: textFieldIconSize,),
                          ),
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
                      Container(
                        height: textFieldSize,
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.black, fontSize:  textFieldFontSize),
                          decoration: InputDecoration(
                            labelText: "Email",
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
                            prefixIcon: Icon(LucideIcons.mail, size: textFieldIconSize,),
                          ),
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
                      Container(
                        height: textFieldSize,
                        child: TextField(
                          controller: passwordController,
                          style: TextStyle(color: Colors.black, fontSize:  textFieldFontSize),
                          obscureText: _isObscure,
                          decoration: InputDecoration(
                            labelText:  "Password",
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
                            prefixIcon: Icon(LucideIcons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_isObscure ? LucideIcons.eyeOff : LucideIcons.eye, size: textFieldIconSize,),
                              onPressed: togglePasswordVisibility, 
                            ),
                          ),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 227, 64, 55),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.white, fontSize:  textFieldFontSize),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Sign In",
                                style: TextStyle(color: Color.fromARGB(255, 11, 129, 240),),
                              ),
                            ),
                          ]
                        ),
                      )
                    ],
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
