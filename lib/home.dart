// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'login.dart';
import 'dart:convert';
import 'statistics.dart';
import 'settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'iconlist.dart';
import 'feedback.dart';

// import 'statistics.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String ip = dotenv.get('IP_ADDRESS');
  List<Map<String, dynamic>> _departments = [];
  final Map<String, IconData> _iconMap = IconDictionary.icons;
  String username = "User"; // Default username
  
  Map<String, bool> isButtonDisabled = {};

  @override
  void initState(){
    super.initState();
    _fetchDepartments();
    _loadUsername(); 
  }
  Future<void> _fetchDepartments() async {
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=getdepartments');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _departments.clear(); 
          _departments = List<Map<String, dynamic>>.from(data);
        });
        isButtonDisabled = {
          for (var department in _departments)
            department["button_name"] as String: false
        };

      } else {
        print("Failed to fetch departments: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching department data: $e");
    }
  }

  Future<void> _sendClickData(int button_id) async {
    String ip = dotenv.get('IP_ADDRESS');
    
    final url = Uri.parse('http://$ip/kpi_itave/store_click.php');
    try {
      final response = await http.post(url, body: {'button_id': button_id.toString()});
      if (response.statusCode == 200) {
        print("Click recorded successfully");
      } else {
        print("Failed to record click: \${response.statusCode}");
      }
    } catch (e) {
      print("Error sending click data: $e");
    }
  }
  
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("uname") ?? "User";
    });
  }


  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _goToStatistics(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StatisticsPage())
    );
  }
  void _goToCustomerFeedBack() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => CustomerFeedback())
    );
  }
  void _goToSettings(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage())
    );
  }
  

  void _incrementCounter(String buttonType, int button_id) async {
    bool? confirmAdd= await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Adding to $buttonType"),
          content: Text("$buttonType Visitor?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirmAdd == true) {
      _sendClickData(button_id);
      Future.delayed(Duration(seconds: 0), () {
        setState(() {
          _fetchDepartments();
        });
      });
    }
  }
  
  Widget _buildCounterCard(String title, String count, String icon, int button_id) {
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonFontSize = 16;
    double titleFontSize = 18;
    double counterFontSize = 30;
    double visitorFont = 10;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: isButtonDisabled[title]! ? null : () =>  _incrementCounter(title,button_id),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    color: Colors.white,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title,
                                        style: GoogleFonts.poppins(
                                          fontSize: titleFontSize, 
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.justify,
                                        softWrap: true,
                                      ),
                                      Container(width: 30, height: 2, color: Color.fromRGBO(111, 5, 6, 1)),
                                    ],
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.05),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(count,
                                      style: GoogleFonts.poppins(
                                        fontSize: counterFontSize, 
                                        color: Colors.black, 
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center
                                    ),
                                    Text('Visitors',
                                      style: GoogleFonts.poppins(
                                        fontSize: visitorFont,
                                        color: Colors.grey[700]
                                      ), 
                                      textAlign: TextAlign.center
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                double availableHeight = constraints.maxHeight; // Get dynamic height

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: availableHeight * 0.1), // Responsive spacing
                                    Icon(_iconMap[icon], size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
                                    SizedBox(height: availableHeight * 0.05), // Responsive spacing
                                  ],
                                );
                              },
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isButtonDisabled[title]! ? null : () { _incrementCounter(title, button_id); },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(53, 53, 63, 1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                ),
                child: Center(
                  child: Text("$title Visitor", style: GoogleFonts.poppins(fontSize: buttonFontSize), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * (screenWidth < 700?  1 : 0.8);
    double containerHeight = MediaQuery.of(context).size.height * 0.9;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(111, 5, 6, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/image/logo.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(widget.title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            PopupMenuButton<int>(
              icon: Icon(Icons.menu, color: Colors.white, size: 30),
              onSelected: (value) {
                if (value == 3) {
                  _logout();
                } else if (value == 2) {
                  _goToSettings();
                } else if (value == 1) {
                  _goToStatistics();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text(username, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(LucideIcons.lineChart, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text("Analytics", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text("Settings", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Logout", style: GoogleFonts.poppins(color: Colors.red)),
                    ],
                  ),
                ),
                
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          // color: Colors.red,
          padding: EdgeInsets.all(0),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(20),
          //   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
          // ),
          child: Column(
            children: [
              Expanded(
                child: _departments.length == 0 ? 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.alertCircle,size: 100,),
                    SizedBox(height: 15,),
                    Text("There is no Department Added")
                  ],
                )
                :
                GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _departments.length, 
                  itemBuilder: (context, index) {
                    return _buildCounterCard(
                      _departments[index]["button_name"] ?? "Unknown",
                      _departments[index]['counter_count']?.toString() ?? "0",
                      _departments[index]["button_icon"] ?? "default_icon",
                      _departments[index]["button_id"] ?? 0,
                    );
                  },
                ),
              ), 
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _goToCustomerFeedBack();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Feedback", style: GoogleFonts.poppins(fontSize: 18)),
                    ),
                  ],
                )
              ),     
            ],
          ),
        ),
      ),
    );
  }
}