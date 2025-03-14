import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'home.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> departments = [
    'Admin',
    'Retail',
    'Technical',
    'Printing',
    'Marketing',
    'Support',
    'Sales',
  ];

  String _searchQuery = '';
  List<String> filteredDepartments = [];
  TextEditingController searchController = TextEditingController();



  @override
  void initState() {
    super.initState();
    filteredDepartments = List.from(departments);
    searchController.addListener(_filterList);
    _pages = getPages();
  }
  
  // void _filterDepartments(String query) {
  //   setState(() {
  //     filteredDepartment = departments
  //         .where((dept) => dept.toLowerCase().contains(query.toLowerCase()))
  //         .toList();
  //   });
  // }
  void _filterList() {
    String query = searchController.text.toLowerCase();
    setState(() {
      print(query);
      filteredDepartments = departments
          .where((department) => department.toLowerCase().contains(query))
          .toList();
      print("Filtered Departments: $filteredDepartments"); // Debugging
    });
  }



  List<Widget> getPages() {
    return [
      _buttonCRUD(),
      _questionCRUD(),
    ];
  }

  late List<Widget> _pages;
  int _selectedIndex = 0;

  

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  Widget _buttonCRUD() {
    // Move `filteredDepartment` here so it updates dynamically
    // List<String> filteredDepartment = departments.keys
    //     .where((key) => key.toLowerCase().contains(_searchQuery.toLowerCase()))
    //     .toList();

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
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "Search Department",
                          border: OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        // onChanged: (value) {
                        //   setState(() {
                        //     _searchQuery = value; 
                        //   });
                        // },
                      ),
                      Card(
                        child: SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: filteredDepartments.length,
                            itemBuilder: (context, index) {
                              print("Building ListTile: ${filteredDepartments[index]}");
                              return ListTile(
                                title: Text(filteredDepartments[index]),
                                onTap: () {
                                  print(filteredDepartments);
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
                      _buttonCard(),
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

  
  Widget _buttonCard() {
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
                                    Text("Admin",
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
                                  Icon(LucideIcons.cakeSlice, size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
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
              onPressed: () => {},
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
                child: Text("Admin Visitor", style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center),
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
                              CupertinoFloatingTab(
                                child: Text('Edit Button'),
                              ),
                              CupertinoFloatingTab(
                                child: Text('Feedback'),
                              ),
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
        // child: Container(
        //   padding: EdgeInsets.all(ResponsiveValue<double>(context, 
        //     defaultValue: 16.0, 
        //     conditionalValues: [
        //       Condition.smallerThan(name: TABLET, value: 12.0),
        //       Condition.largerThan(name: TABLET, value: 24.0),
        //     ],
        //   ).value),
        //   constraints: const BoxConstraints(maxWidth: 800),
        child: _pages.elementAt(_selectedIndex), 
          // Text(
          //   "Settings Page Content",
          //   style: GoogleFonts.poppins(
          //     fontSize: ResponsiveValue<double>(context, 
          //       defaultValue: 16.0, 
          //       conditionalValues: [
          //         Condition.smallerThan(name: TABLET, value: 14.0),
          //         Condition.largerThan(name: TABLET, value: 18.0),
          //       ],
          //     ).value,
          //   ),
          // ),
        // ),
      ),
    );
  }
}
