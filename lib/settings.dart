import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  IconData iconData = IconData(0xf569, fontFamily: 'LucideIcons');
  int? _selectedDepartment;
  List<Map<String, dynamic>> _departments = [];
  
  
  String ip = dotenv.get('IP_ADDRESS');
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  void _fetchDepartments() async {
    String ip = dotenv.get('IP_ADDRESS');
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=getdepartments&filter=$_searchQuery');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _departments.clear(); 
          _departments = List<Map<String, dynamic>>.from(data);
        });

      } else {
        print("Failed to fetch departments: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching department data: $e");
    }
  }



  

  late List<Widget> _pages;
  int _selectedIndex = 0;

  

  @override
  void dispose() {
    super.dispose();
  }
  Widget _buttonCRUD() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Departments',
                    style: GoogleFonts.poppins(
                      fontSize: 20, 
                      color: const Color.fromARGB(255, 0, 0, 0)
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => {print("Edit Button Pressed")},
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.square_pencil_fill,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          size: 15,
                        ),
                        SizedBox(width: 2),
                        Text(
                          "Edit",
                          style: GoogleFonts.poppins(
                            fontSize: 15, 
                            color: const Color.fromARGB(255, 0, 0, 0)
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Search Department",
                          border: OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _fetchDepartments();
                        },
                      ),
                      Card(
                        child: SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: _departments.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_departments[index]['button_name'] ,),
                                onTap: () {
                                  setState(() {
                                    _selectedDepartment = index;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [                      
                      _selectedDepartment != null 
                        ? _buttonCard(_selectedDepartment!) 
                        : _buttonCard(0) ,
                      Container(
                        width: 70,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () => {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15))
                            ),
                          ),
                          child: Center(
                            child: Icon(LucideIcons.plus, size: 20,),
                          ),
                        ),
                      )
                    ],
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buttonCard(int department){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 350,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
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
                                    Text(_departments.length != 0 ? _departments[department]["button_name"] : "Department",
                                      style: GoogleFonts.poppins(
                                        fontSize: 20, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.justify,
                                      softWrap: true,
                                    ),
                                    Container(width: 40, height: 5, color: Color.fromRGBO(111, 5, 6, 1)),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('100',
                                    style: GoogleFonts.poppins(
                                      fontSize: 25, 
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center
                                  ),
                                  Text('Visitors',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
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
                                  SizedBox(height: availableHeight * 0.1), 
                                  Icon(_departments.length != 0 ? IconData(0xf569, fontFamily: 'LucideIcons') : LucideIcons.cakeSlice, size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
                                  SizedBox(height: availableHeight * 0.05),
                                  

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
              onPressed: () => {
                print(_departments),
                print(LucideIcons.userCircle2.codePoint)
              },
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
                child: Text(_departments.length != 0 ? _departments[department]["button_name"]+" Visitor": "Department Visitor", style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCRUD() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue,
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Survey Questionaires',
                    style: GoogleFonts.poppins(fontSize: 20, color: const Color.fromARGB(255, 0, 0, 0)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            
          ],
        ),
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    List<Widget> getPages() {
      return [
        _buttonCRUD(),
        _questionCRUD(),
      ];
    }
    _pages = getPages();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(111, 5, 6, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home Page')),
                    );
                  },
                  icon: const Icon(LucideIcons.arrowLeftCircle, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(
                  "Settings",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: ResponsiveValue<double>(context, 
                      defaultValue: 18.0, 
                      conditionalValues: [
                        Condition.smallerThan(name: TABLET, value: 16.0),
                        Condition.largerThan(name: TABLET, value: 20.0),
                      ],
                    ).value,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: SafeArea(
                    child: DefaultTabController(
                      length: 2,
                      child: Builder(
                        builder: (context) {
                          return CupertinoFloatingTabBar(
                            isVibrant: true,
                            onDestinationSelected: (value) {
                                setState(() {
                                  _selectedIndex = value;
                                });
                            },
                            tabs: const [
                                CupertinoFloatingTab(child: Text('Edit Button')),
                                CupertinoFloatingTab(child: Text('Feedback')),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: Container(
        child: _pages.elementAt(_selectedIndex), 
      ),
    );
  }
}
