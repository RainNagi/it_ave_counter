// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bloc/navigator.dart';
import 'bloc/counter.dart';
import 'repository/fetch_department.dart';
import '../common/iconlist.dart';

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<String, IconData> _iconMap = IconDictionary.icons;
  String username = "User"; 
  List<Map<String, dynamic>> departments = [];
  Map<String, bool> isButtonDisabled = {};

  @override
  void initState(){
    super.initState();
    loadDepartments();
    _loadUsername(); 
  }

  void loadDepartments() async {
    List<Map<String, dynamic>> fetchedDepartments = await fetchDepartments();
    setState(() {
      departments = fetchedDepartments;
      isButtonDisabled = {
        for (var department in departments) department["button_name"] as String: false
      };
    });
  }

  void _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("uname") ?? "User";
    });
  }

  Widget _buildCounterCard(String title, String count, String icon, int buttonId) {
    
    double buttonFontSize = 16;
    double titleFontSize = 18;
    double counterFontSize = 30;
    double visitorFont = 10;
    // var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    // double buttonFontSize;
    // double titleFontSize;
    // double counterFontSize;
    // double visitorFont;

    // if (screenType == MOBILE) {
    //   buttonFontSize = 10;
    //   titleFontSize = 12;
    //   counterFontSize = 20;
    //   visitorFont = 10;
    // } else {
    //   buttonFontSize = 16;
    //   titleFontSize = 18;
    //   counterFontSize = 30;
    //   visitorFont = 10;
    // }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: isButtonDisabled[title]! ? null : () {incrementCounter(title,buttonId,context, loadDepartments);},
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
                onPressed: isButtonDisabled[title]! ? null : () { incrementCounter(title, buttonId, context, loadDepartments);},
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
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * (screenWidth < 700?  1 : 0.8);
    double containerHeight = MediaQuery.of(context).size.height * 0.9;
    double titleSize = screenType == MOBILE ? 15 : 20;
    double navSize = screenType == MOBILE ? 25 : 30;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(111, 5, 6, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ResponsiveRowColumn(
            //   layout: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
            //       ? ResponsiveRowColumnType.COLUMN
            //       : ResponsiveRowColumnType.ROW,
            //   children: [
            //     ResponsiveRowColumnItem(
            //       child: Expanded(child: Text("Left Section")),
            //     ),
            //     ResponsiveRowColumnItem(
            //       child: Expanded(child: Text("Right Section")),
            //     ),
            //   ],
            // ),
            ClipOval(
              child: Container(
                color: Colors.white,
                child: Image.asset(
                  'assets/image/logo.png',
                  width: navSize,
                  height: navSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(widget.title, style: GoogleFonts.poppins(color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.bold)),
            PopupMenuButton<int>(
              icon: Icon(Icons.menu, color: Colors.white, size: navSize),
              onSelected: (value) {
                if (value == 3) {
                  logout(context);
                } else if (value == 2) {
                  goToSettings(context);
                } else if (value == 1) {
                  goToStatistics(context);
                } else if (value == 0) {
                  print(departments);
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
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Expanded(
                child: departments.isEmpty ? 
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenType == DESKTOP ? 3 : screenType == TABLET ? 2 : 1, 
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: departments.length, 
                  itemBuilder: (context, index) {
                    return _buildCounterCard(
                      departments[index]["button_name"] ?? "Unknown",
                      departments[index]['counter_count']?.toString() ?? "0",
                      departments[index]["button_icon"] ?? "default_icon",
                      departments[index]["button_id"] ?? 0,
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
                        goToCustomerFeedBack(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Feedback", style: GoogleFonts.poppins(fontSize: screenType == MOBILE? 10 : 18 )),
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