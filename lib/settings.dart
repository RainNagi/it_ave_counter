// ignore_for_file: avoid_print, deprecated_member_use

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
import 'iconlist.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String ip = dotenv.get('IP_ADDRESS');

  final Map<String, IconData> _iconMap = IconDictionary.icons;
  List<Map<String, dynamic>> _departments = [];
  bool _isAddingDepartment = false;
  bool _isEditDepartment = false;
  int _selectedDepartment = 0;
  String _selectedIcon = "lucide_plus_circle";
  
  String _newDepartmentName = "";
  TextEditingController departmentNameController = TextEditingController();

  String _iconSearchQuery = '';
  String _searchQuery = '';


  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
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
  Future<void> _archiveDepartment(selectedDepartment) async {
    int deptId = _departments[selectedDepartment]["button_id"];
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=archiveDepartment');
    try {
      final response = await http.post(url, body: {'departmentId': deptId.toString()});
      if (response.statusCode == 200) {
        _fetchDepartments();
      } else {
        print("Failed to archive department: ${response.statusCode}");
      }
    } catch (e) {
      print("Error archiving department data: $e");
    }
  }
  void _addDepartment() async {
    if (departmentNameController.text.trim().isEmpty) {
      _showDialog("Error", "Department name cannot be empty.");
      return;
    }
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=addDepartment');
    try {
      final response = await http.post(
        url,
        body: {
          'button_name': _newDepartmentName,
          'button_icon': _selectedIcon,
        },
      );
      final responseData = jsonDecode(response.body);
      _showDialog(
        responseData['status'] == 'error' ? "Error" : "Success",
        responseData['message'],
      );
      if (responseData['status'] == 'success') {
        setState(() {
          _isAddingDepartment = false;
          _newDepartmentName = "";
          _selectedIcon = "lucide_plus_circle";
          departmentNameController.clear();
        });
      }
    } catch (e) {
      _showDialog("Error", "Failed to add department: $e");
    }
  }
  void _editDepartment() async{
    if (departmentNameController.text.trim().isEmpty) {
      _showDialog("Error", "Name cannot be empty.");
      return;
    }
    int deptId = _departments[_selectedDepartment]["button_id"];
    String defaultIcon = _departments[_selectedDepartment]["button_icon"];

    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=editDepartment');
    try {
      final response = await http.post(
        url,
        body: {
          'button_id' : deptId.toString(),
          'button_name': _newDepartmentName,
          'button_icon': _selectedIcon == "lucide_plus_circle"? defaultIcon : _selectedIcon,
        },
      );

      final responseData = jsonDecode(response.body);

      _showDialog(
        responseData['status'] == 'error' ? "Error" : "Success",
        responseData['message'],
      );

      if (responseData['status'] == 'success') {
        setState(() {
          _isEditDepartment = false;
          _newDepartmentName = "";
          _selectedIcon = "lucide_plus_circle";
          departmentNameController.clear();
          _fetchDepartments();
        });
      }
    } catch (e) {
      _showDialog("Error", "Failed to edit department: $e");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }



  late List<Widget> _pages;
  int _selectedIndex = 0;

  @override
  void dispose() {
    super.dispose();
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
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0)
                    ),
                  ),
                  _isAddingDepartment || _isEditDepartment ?
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isAddingDepartment = false;
                          _isEditDepartment = false;
                          _newDepartmentName = "";
                          _selectedIcon = "lucide_plus_circle";
                          departmentNameController.clear();
                        }),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.xCircle,
                              color: const Color.fromARGB(255, 156, 20, 20),
                              size: 15,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 15, 
                                color: const Color.fromARGB(255, 156, 20, 20)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  )
                  :
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Confirm Delete"),
                                content: Text("Are you sure you want to delete this?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text("Delete", style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmDelete == true) {
                            _archiveDepartment(_selectedDepartment);
                          }
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.delete,
                              color: Color.fromARGB(255, 0, 0, 0),
                              size: 15,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "Delete",
                              style: GoogleFonts.poppins(
                                fontSize: 15, 
                                color: Color.fromARGB(255, 144, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isEditDepartment = true;
                        }),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.edit,
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
                  )
                  
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
                            _selectedDepartment = 0;
                          });
                          _fetchDepartments();
                        },
                      ),
                      Card(
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                itemCount: _departments.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_departments[index]['button_name'] ,),
                                    onTap: () {
                                      setState(() {
                                        _selectedDepartment = index;
                                        print(_selectedDepartment);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            if (_isAddingDepartment || _isEditDepartment)
                              Positioned.fill(
                                child: AbsorbPointer(
                                  absorbing: true, 
                                  child: Container(
                                    color: Colors.black.withOpacity(0.1), 
                                  ),
                                ),
                              ),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [                      
                      _selectedDepartment != 0 
                        ? _buttonCard(_selectedDepartment) 
                        : _buttonCard(0),
                      _isAddingDepartment || _isEditDepartment?
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            bool? confirmAdd = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  // ignore: prefer_interpolation_to_compose_strings
                                  title: _isAddingDepartment? Text("Adding Department") :Text("Editing "+_departments[_selectedDepartment]["button_name"]+ " Department"),
                                  content: Text("Are you sure you want to save this?"),
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
                              _isAddingDepartment? _addDepartment() : _editDepartment();
                              _fetchDepartments();
                              
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.save,
                                color: const Color.fromARGB(255, 0, 0, 0),
                                size: 15,
                              ),
                              SizedBox(width: 2),
                              Text(
                                "Save",
                                style: GoogleFonts.poppins(
                                  fontSize: 15, 
                                  color: const Color.fromARGB(255, 0, 0, 0)
                                ),
                              ),
                            ],
                          ),
                        )
                      )
                      :
                      SizedBox(
                        width: 70,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () => setState(() {
                             _isAddingDepartment = true;
                            _newDepartmentName = "";
                            // _selectedIcon = null;
                          }),
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
                                     _isAddingDepartment || _isEditDepartment
                                      ? SizedBox(
                                        width: 400,
                                        child: Column(
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(labelText: _isEditDepartment ? _departments[department]["button_name"] : "Department Name"),
                                              controller: departmentNameController,
                                              onChanged: (value) => setState(() => _newDepartmentName = value),
                                            ),
                                            SizedBox(height: 10,),
                                          ],
                                        )
                                      )
                                      : Text(
                                          _departments.isNotEmpty ? _departments[department]["button_name"] : "Department",
                                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                    Container(width: 40, height: 5, color: Color.fromRGBO(111, 5, 6, 1)),
                                  ],
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.05),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _isAddingDepartment
                                  ? 
                                  Text("100",
                                    style: GoogleFonts.poppins(
                                      fontSize: 25, 
                                      color: Colors.black, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    textAlign: TextAlign.center
                                  ) :
                                  Text(_departments.isNotEmpty ? _departments[department]['counter_count'].toString() : "100",
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
                                  _isAddingDepartment || _isEditDepartment?
                                  GestureDetector(
                                    onTap:()=> setState(() {
                                      _showIconPickerDialog();
                                    }),
                                    child: Icon(
                                      _selectedIcon == 'lucide_plus_circle' ? IconDictionary.icons[_departments[department]["button_icon"]] :_iconMap[_selectedIcon],
                                      size: availableHeight * 0.5,
                                      color: Color.fromRGBO(151, 81, 2, 1),
                                    ),
                                  ):
                                  Icon(_departments.isNotEmpty ? IconDictionary.icons[_departments[department]["button_icon"]] : LucideIcons.plusCircle, size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
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
                // print(_departments)
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
                child: 
                _isAddingDepartment || _isEditDepartment?
                Text("$_newDepartmentName Visitor", style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center)
                :
                Text(_departments.isNotEmpty ? _departments[department]["button_name"]+" Visitor": "Department Visitor", style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showIconPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> filteredIcons = _iconMap.keys
                .where((key) => key.toLowerCase().contains(_iconSearchQuery.toLowerCase()) && key != "lucide_plus_circle")
                .toList();
            return AlertDialog(
              title: const Text("Icon Picker"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Search Icon",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _iconSearchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: filteredIcons.length,
                      itemBuilder: (context, index) {
                        String iconName = filteredIcons[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = iconName;
                            });
                            _fetchDepartments();
                            Navigator.pop(context);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_iconMap[iconName], size: 40, color: Colors.black),
                              Text(iconName, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
}
