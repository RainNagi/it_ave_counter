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
  List<Widget> getPages() {
    return [
      _buttonCRUD(),
      const Text('Page 2'),
    ];
  }

  late List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages = getPages();
  }

  
  Widget _buttonCRUD() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.blue,
      child: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text('Departments',
                      style: GoogleFonts.poppins(fontSize: 20,),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => {print("button is Pressed")},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.square_pencil_fill, color: const Color.fromARGB(255, 0, 0, 0)),
                      SizedBox(width: 2),
                      Text("Edit", style: GoogleFonts.poppins(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row (
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Colors.red,
                  width: 200,
                  height: 300,
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          top: 20
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                            )
                          )
                        ),
                        child: Text('Admin'),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 20
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                            )
                          )
                        ),
                        child: Text('Admin'),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 20
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                            )
                          )
                        ),
                        child: Text('Admin'),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          top: 20
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                            )
                          )
                        ),
                        child: Text('Admin'),
                      ),
                    ],
                  ),
                )
              ]
            )
          ],
        )
      ),
      // child: Container(
      //   padding: EdgeInsets.all(5),
      //   decoration: BoxDecoration(
      //     border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
      //     borderRadius: BorderRadius.circular(15),
      //   ),
      //   child: InkWell(
      //     onTap: () {
      //       print("Button Pressed!");
      //     },
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: [
      //         Expanded(
      //           child: Container(
      //             padding: EdgeInsets.all(10),
      //             decoration: BoxDecoration(
      //               borderRadius: BorderRadius.only(
      //                 topLeft: Radius.circular(15),
      //                 topRight: Radius.circular(15),
      //               ),
      //               color: Colors.white,
      //             ),
      //             child: LayoutBuilder(
      //               builder: (context, constraints) {
      //                 double screenWidth = constraints.maxWidth;
      //                 return Column(
      //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: [
      //                     Padding(
      //                       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                         children: [
      //                           Expanded(
      //                             child: Column(
      //                               crossAxisAlignment: CrossAxisAlignment.start,
      //                               children: [
      //                                 Text("Info",
      //                                   style: GoogleFonts.poppins(
      //                                     fontSize: 12, 
      //                                     fontWeight: FontWeight.bold,
      //                                   ),
      //                                   textAlign: TextAlign.justify,
      //                                   softWrap: true,
      //                                 ),
      //                                 Container(width: 30, height: 2, color: Color.fromRGBO(111, 5, 6, 1)),
      //                               ],
      //                             ),
      //                           ),
      //                           SizedBox(width: screenWidth * 0.05),
      //                           Column(
      //                             crossAxisAlignment: CrossAxisAlignment.end,
      //                             children: [
      //                               Text('0',
      //                                 style: GoogleFonts.poppins(
      //                                   fontSize: 20, 
      //                                   color: Colors.black, 
      //                                   fontWeight: FontWeight.bold
      //                                 ),
      //                                 textAlign: TextAlign.center
      //                               ),
      //                               Text('Visitors',
      //                                 style: GoogleFonts.poppins(
      //                                   fontSize: 8,
      //                                   color: Colors.grey[700]
      //                                 ), 
      //                                 textAlign: TextAlign.center
      //                               ),
      //                             ],
      //                           )
      //                         ],
      //                       ),
      //                     ),
      //                     Expanded(
      //                       child: LayoutBuilder(
      //                         builder: (context, constraints) {
      //                           double availableHeight = constraints.maxHeight; // Get dynamic height

      //                           return Column(
      //                             crossAxisAlignment: CrossAxisAlignment.center,
      //                             mainAxisAlignment: MainAxisAlignment.center,
      //                             children: [
      //                               SizedBox(height: availableHeight * 0.1), // Responsive spacing
      //                               Icon(LucideIcons.info, size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
      //                               SizedBox(height: availableHeight * 0.05), // Responsive spacing
      //                             ],
      //                           );
      //                         },
      //                       ),
      //                     )
      //                   ],
      //                 );
      //               },
      //             ),
      //           ),
      //         ),
      //         ElevatedButton(
      //           onPressed: () {
      //             print("Button Pressed!");
      //           },
      //           style: ElevatedButton.styleFrom(
      //             backgroundColor: Color.fromRGBO(53, 53, 63, 1),
      //             foregroundColor: Colors.white,
      //             padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.only(
      //                 bottomLeft: Radius.circular(15),
      //                 bottomRight: Radius.circular(15),
      //               ),
      //             ),
      //           ),
      //           child: Center(
      //             child: Text("Admin Visitor", style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
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
