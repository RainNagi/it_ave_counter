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
import 'test1.dart';

// import 'statistics.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  String username = "User"; // Default username
  int adminCounter = 0;
  int technicalCounter = 0;
  int retailInquiryCounter = 0;
  int printingAvenueCounter = 0;
  
  Map<String, bool> isButtonDisabled = {
    "Admin": false,
    "Technical": false,
    "Retail Inquiry": false,
    "Printing Avenue": false,
  };
  @override
  void initState(){
    super.initState();
    _fetchClickCounts();
    _loadUsername();
    
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
  Future<void> _fetchClickCounts() async {
    String ip = dotenv.get('IP_ADDRESS');
    final url = Uri.parse('http://$ip/kpi_itave/store_click.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          adminCounter = int.tryParse(data["Admin"].toString()) ?? 0;
          technicalCounter = int.tryParse(data["Technical"].toString()) ?? 0;
          retailInquiryCounter = int.tryParse(data["Retail Inquiry"].toString()) ?? 0;
          printingAvenueCounter = int.tryParse(data["Printing Avenue"].toString()) ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching counts: $e");
    }
  }
  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "User";
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
  void _goToSettings(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage())
    );
  }
  void _goToTest(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TestPage())
    );
  }

  void _incrementCounter(String buttonType, int button_id) {
    if (isButtonDisabled[buttonType] == true) return;

    setState(() {
      isButtonDisabled[buttonType] = true;
    });

    _sendClickData(button_id).then((_) => _fetchClickCounts());

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        isButtonDisabled[buttonType] = false;
      });
    });
  }

  Widget _buildCounterCard(String title, int count, IconData icon, int button_id) {
    
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonFontSize = 16;
    double titleFontSize = 18;
    double counterFontSize = 30;
    double visitorFont = 10;
    // double iconSize = 64;
    // double horizontalPadding = 20;
    if (screenHeight < 850) {
      if (screenWidth < 500) {
        buttonFontSize = 10;
        titleFontSize = 10;
        counterFontSize = 12;
        visitorFont = 5;
        // iconSize = 64;
        // horizontalPadding = 5;
      } else if (screenWidth < 600) {
        buttonFontSize = 15;
        titleFontSize = 20;
        counterFontSize = 30;
        visitorFont = 12;
        // iconSize = 70;
        // horizontalPadding = 5;
      }
    } else {
        if (screenWidth < 500) {
        buttonFontSize = 16;
        titleFontSize = 15;
        counterFontSize = 19;
        visitorFont = 5;
        // iconSize = 64;
        // horizontalPadding = 5;
      } else if (screenWidth < 650) {
        buttonFontSize = 15;
        titleFontSize = 20;
        counterFontSize = 30;
        visitorFont = 12;
        // iconSize = 100;
        // horizontalPadding = 5;
      } else {
        buttonFontSize = 20;
        titleFontSize = 20;
        counterFontSize = 40;
        visitorFont = 13;
        // iconSize = 60;
        // horizontalPadding = 20;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: isButtonDisabled[title]! ? null : () => _incrementCounter(title,button_id),
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
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
                                    Text('$count',
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
                                    Icon(icon, size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
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
                onPressed: isButtonDisabled[title]! ? null : () => _incrementCounter(title, button_id),
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
              icon: Icon(Icons.account_circle, color: Colors.white, size: 30),
              onSelected: (value) {
                if (value == 3) {
                  _logout();
                } else if (value == 2) {
                  _goToSettings();
                } else if (value == 1) {
                  _goToStatistics();
                } else if (value == 4) {
                  _goToTest();
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
                      Icon(Icons.analytics, color: const Color.fromARGB(255, 0, 0, 0)),
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
                PopupMenuDivider(),
                PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(LucideIcons.activity, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 8),
                      Text("Test", style: GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0))),
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
          padding: EdgeInsets.all(16),
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(20),
          //   boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
          // ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildCounterCard("Admin", adminCounter, LucideIcons.userCircle2, 1)),
                    SizedBox(width: 10),
                    Expanded(child: _buildCounterCard("Technical", technicalCounter, LucideIcons.settings, 2)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildCounterCard("Retail Inquiry", retailInquiryCounter, LucideIcons.shoppingCart, 3)),
                    SizedBox(width: 10),
                    Expanded(child: _buildCounterCard("Printing Avenue", printingAvenueCounter, LucideIcons.printer, 4)),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // _goToCustomerFeedBack();
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