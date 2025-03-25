// ignore_for_file: avoid_print, deprecated_member_use, prefer_final_fields, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rating_and_feedback_collector/rating_and_feedback_collector.dart';
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
  String _iconSearchQuery = '';
  String _selectedIcon = "lucide_plus_circle";

  // Button CRUD
  List<Map<String, dynamic>> _departments = [];
  bool _isAddingDepartment = false;
  bool _isEditingDepartment = false;
  int _selectedDepartment = 0;
  String _newDepartmentName = "";
  TextEditingController departmentNameController = TextEditingController();
  String _searchQuery = '';

  // question CRUD
  List<Map<String, dynamic>> _questions = [];
  bool _isAddingQuestion = false;
  bool _isEditingQuestion = false;
  int _selectedQuestion = 1;
  double _rating = 2.5;
  TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _fetchDepartments();

  }

  // button CRUD
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
  Future<void> _archiveDepartment(int selectedDepartment) async {
    if (selectedDepartment < 0 || selectedDepartment >= _departments.length) {
      print("Invalid department index.");
      return;
    }
    int deptId = _departments[selectedDepartment]["button_id"];
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=archiveDepartment');
    try {
      final response = await http.post(url, body: {'departmentId': deptId.toString()});
      if (response.statusCode == 200) {
        await _fetchDepartments();

        if (_departments.isEmpty) {
          _selectedDepartment = 0; 
        } else if (_selectedDepartment >= _departments.length) {
          _selectedDepartment = _departments.length - 1; 
        }

        setState(() {}); // Update UI
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
      _fetchDepartments();
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
          _isEditingDepartment = false;
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

  // question CRUD
  Future<void> _fetchQuestions() async {
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=getQuestions');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);

          setState(() {
            _questions.clear(); 
            _questions = List<Map<String, dynamic>>.from(data);
          });

        } else {
          print("Failed to fetch questions: ${response.statusCode}");
        }
      } else {
        print("Failed to fetch questions: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching questions data: $e");
    }
  }
  void _addQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      _showDialog("Error", "Question cannot be empty.");
      return;
    }
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=addQuestion');
    try {
      final response = await http.post(
        url,
        body: {
          'question': _questionController.text,
        },
      );
      final responseData = jsonDecode(response.body);
      _showDialog(
        responseData['status'] == 'error' ? "Error" : "Success",
        responseData['message'],
      );
      if (responseData['status'] == 'success') {
        setState(() {
          _isAddingQuestion = false;
          _questionController.clear();
          _fetchQuestions();
        });
      }
    } catch (e) {
      _showDialog("Error", "Failed to add department: $e");
    }
  }
  Future<void> _archiveQuestion() async {
    if (_selectedQuestion-1 < 0 || _selectedQuestion-1 >= _questions.length) {
      print("Invalid Question index.");
      return;
    }
    print(_questions[_selectedQuestion-1]["question_id"]);
    int questionId = _questions[_selectedQuestion-1]["question_id"];
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=archiveQuestion');
    try {
      final response = await http.post(url, body: {'questionId': questionId.toString()});
      // print("Calling this function"+ questionId.toString());
      if (response.statusCode == 200) {
        await _fetchQuestions();
        setState(() {});
      } else {
        print("Failed to archive Question: ${response.statusCode}");
      }
    } catch (e) {
      print("Error archiving question data: $e");
    }
  }
  void _editQuestion() async{
    if (_questionController.text.trim().isEmpty) {
      _showDialog("Error", "Question cannot be empty.");
      return;
    }
    print(_questions[_selectedQuestion-1]["question_id"]);
    int quesId = _questions[_selectedQuestion-1]["question_id"];
    // String defaultIcon = _departments[_selectedDepartment]["button_icon"];
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=editQuestion');
    try {
      final response = await http.post(
        url,
        body: {
          'question_id' : quesId.toString(),
          'question' : _questionController.text
        },
      );
      final responseData = jsonDecode(response.body);
      _showDialog(
        responseData['status'] == 'error' ? "Error" : "Success",
        responseData['message'],
      );
      if (responseData['status'] == 'success') {
        setState(() {
          _isEditingQuestion = false;
          _questionController.clear();
          _fetchQuestions();
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
                  _isAddingDepartment || _isEditingDepartment ?
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isAddingDepartment = false;
                          _isEditingDepartment = false;
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
                  : _departments.isEmpty ? Text("") :
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
                          _isEditingDepartment = true;
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
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            if (_isAddingDepartment || _isEditingDepartment)
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
                      _isAddingDepartment || _isEditingDepartment?
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            bool? confirmAdd = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
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
                                     _isAddingDepartment || _isEditingDepartment
                                      ? SizedBox(
                                        width: 400,
                                        child: Column(
                                          children: [
                                            TextField(
                                              decoration: InputDecoration(labelText: _isEditingDepartment ? _departments[department]["button_name"] : "Department Name"),
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
                                  _isAddingDepartment || _isEditingDepartment?
                                  GestureDetector(
                                    onTap:()=> setState(() {
                                      _showIconPickerDialog();
                                    }),
                                    child: Icon(
                                      _selectedIcon == 'lucide_plus_circle' && _isEditingDepartment ? IconDictionary.icons[_departments[department]["button_icon"]] :_iconMap[_selectedIcon],
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
                _isAddingDepartment || _isEditingDepartment?
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
                        return  GestureDetector(
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
      // color: Colors.blue,
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
                  _isAddingQuestion || _isEditingQuestion ?
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isAddingQuestion = false;
                          _isEditingQuestion = false;
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
                  _questions.isEmpty ? Text("") :
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
                            _archiveQuestion();
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
                          _isEditingQuestion = true;
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 70),
              height: 300,
              child: _questionCard()
            ),
            SizedBox(height: 10,),
            _isAddingQuestion || _isEditingQuestion ?
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  bool? confirmAdd = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: _isAddingQuestion? Text("Adding Question") :Text("Editing Question "+_selectedQuestion.toString()+ "?"),
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
                    _isAddingQuestion? _addQuestion() : _editQuestion();
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
              height: 40,
              child: SizedBox(
                width: 70,
                child: 
                ElevatedButton(
                  onPressed: () => setState(() {
                    _isAddingQuestion = true;
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
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: SizedBox(
                width: 1000,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return _questionListCard(index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _questionListCard(int id) {
    int questionNo = id + 1; 
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          _isEditingQuestion || _isAddingQuestion ? print("None") :
          setState(() {
            _selectedQuestion = questionNo;
            _fetchQuestions();
            print("Questions: $_questions,$_selectedQuestion");
          });
        },
        child: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Question $questionNo",
                  style: GoogleFonts.poppins(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
                SizedBox(height: 5),
                Container(width: 30, height: 2, color: Color.fromRGBO(111, 5, 6, 1)),
              ],
            ),
          ),
        ),
      )
    );
  }


  Widget _questionCard() {
    int num = _questions.length + 1;
    return 
    Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(91, 0, 0, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double availableWidth = constraints.maxWidth;
                  return Container(
                    width: availableWidth,
                    height: 280,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: availableWidth * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _questions.isEmpty ? "Questions 0" :
                                    _isAddingQuestion? "Question $num" : "Question $_selectedQuestion",
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.justify,
                                    softWrap: true,
                                  ),
                                  Container(width: 30, height: 2, color: Color.fromRGBO(111, 5, 6, 1)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: availableWidth - 20,
                              height: 210,
                              color: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  (_isAddingQuestion || _isEditingQuestion)
                                      ? TextField(
                                          controller: _questionController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: "Enter question...",
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                        )
                                      : Text(
                                          _questions.isEmpty ? "There is no Question" : _questions[_selectedQuestion - 1]["question"],
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          softWrap: true,
                                        ),
                                  SizedBox(height: 30),
                                  _questions.isEmpty ? 
                                  SizedBox(height: 30) :
                                  RatingBar(
                                    iconSize: 40,
                                    allowHalfRating: true,
                                    filledIcon: Icons.star,
                                    halfFilledIcon: Icons.star_half,
                                    emptyIcon: Icons.star_border,
                                    filledColor: Colors.amber,
                                    emptyColor: Colors.grey,
                                    currentRating: _rating,
                                    onRatingChanged: (rating) {
                                      setState(() {
                                        // _rating = rating;
                                        // print(_rating);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
