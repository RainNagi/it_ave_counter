// ignore_for_file: avoid_print, deprecated_member_use, prefer_final_fields, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../home/home.dart';
import 'widgets/widget_cards.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String ip = dotenv.get('IP_ADDRESS');  
  
  String _selectedIcon = "lucide_plus_circle";

  // Button CRUD
  List<Map<String, dynamic>> _departments = [];
  bool _isAddingDepartment = false;
  bool _isEditingDepartment = false;
  int _selectedDepartment = 0;
  TextEditingController departmentNameController = TextEditingController();
  String _searchQuery = '';

  // question CRUD
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> filteredQuestions = [];
  bool _isAddingQuestion = false;
  bool _isEditingQuestion = false;
  int _selectedQuestion = 0;
  int _selectedDepartmentInQuestion = -1;
  TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _fetchDepartments();
    filterQuestionsByDepartment();
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
  Future<void> _restoreDepartment(int id) async {
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=buttons&action=restoreDepartment');
    try {
      final response = await http.post(url, body: {'departmentId': id.toString()});
      if (response.statusCode == 200) {
        await _fetchDepartments();
        setState(() {
          _isAddingDepartment = false;
        }); // Update UI
      } else {
        print("Failed to archive department: ${response.statusCode}");
      }
    } catch (e) {
      print("Error archiving department data: $e");
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
          'button_name': departmentNameController.text,
          'button_icon': _selectedIcon,
        },
      );
      final responseData = jsonDecode(response.body);
      _fetchDepartments();
      if (responseData['status'] == "disabled") {
        _showConfirmCancelDialog (
          responseData["message"],
          "Do You Want to Restore Department",
          responseData["id"],
          "department"
        );
      } else {
        _showDialog(
          responseData['status'] == 'error' ? "Error" : "Success",
          responseData['message'],
        );
      }
      if (responseData['status'] == 'success') {
        setState(() {
          _isAddingDepartment = false;
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
          'button_name': departmentNameController.text,
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
          _selectedIcon = "lucide_plus_circle";
          departmentNameController.clear();
          _fetchDepartments();
        });
      }
    } catch (e) {
      _showDialog("Error", "Failed to edit department: $e");
    }
  }
  void cancelAll() {
    setState(() {
      _isEditingQuestion = false;
      _isAddingDepartment = false;
      _isEditingDepartment = false;
      _isAddingQuestion = false;
      _questionController.clear();
      departmentNameController.clear();
    });
    return ;
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
            filterQuestionsByDepartment();
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
  void filterQuestionsByDepartment() {
    
    if (_selectedDepartmentInQuestion == -1) {
      filteredQuestions = _questions
          .where((q) => q['department_id'] == 0)
          .toList();
    } else {
      filteredQuestions = _questions
          .where((q) => q['department_id'] == _departments[_selectedDepartmentInQuestion]["button_id"])
          .toList();
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
          'department': _selectedDepartmentInQuestion == -1 ? "0" : _departments[_selectedDepartmentInQuestion]['button_id'].toString(),
        },
      );
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == "disabled") {
        _showConfirmCancelDialog (
          responseData["message"],
          "Do You Want to Restore Question",
          responseData["id"],
          "question"
        );
      } else {
        _showDialog(
          responseData['status'] == 'error' ? "Error" : "Success",
          responseData['message'],
        );
      }
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
    if (_selectedQuestion < 0 || _selectedQuestion >= _questions.length) {
      print("Invalid Question index.");
      return;
    }
    int questionId = _questions[_selectedQuestion]["question_id"];
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=archiveQuestion');
    try {
      final response = await http.post(url, body: {'questionId': questionId.toString()});
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
  Future<void> _restoreQuestion(int id) async{
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=restoreQuestion');
    try {
      final response = await http.post(url, body: {'questionId': id.toString()});
      if (response.statusCode == 200) {
        await _fetchQuestions();
        setState(() {
          _isAddingQuestion = false;
        });
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
    // String defaultIcon = _departments[_selectedDepartment]["button_icon"];
    final url = Uri.parse('http://$ip/kpi_itave/settings.php?section=questions&action=editQuestion');
    try {
      final response = await http.post(
        url,
        body: {
          'question_id' : filteredQuestions[_selectedQuestion]["question_id"].toString(),
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

  void _showConfirmCancelDialog(String title, String message, int id, String type) async{
    bool? confirmRestore = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
    if (confirmRestore == true) {
      if (type == "department") {
        _restoreDepartment(id);
        _fetchDepartments();
      } else if (type == "question") {
        _restoreQuestion(id);
        _fetchDepartments();
      }
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
  Widget buildPage() {
    var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
    if (screenType == MOBILE) {
      return _phonePages.elementAt(_selectedIndex);
    } else if (screenType == TABLET) {
      return _tabletPages.elementAt(_selectedIndex);
    } else {
      return _pages.elementAt(_selectedIndex);
    }
  }




  late List<Widget> _pages;
  late List<Widget> _tabletPages;
  late List<Widget> _phonePages;
  int _selectedIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> getPages() {
      return [
        _buttonCRUDDesktop(),
        _questionCRUDDesktop(),
      ];
    }
    List<Widget> getTabletPages() {
      return [
        _buttonCRUDTablet(),
        _questionCRUDTablet(),
      ];
    }
    List<Widget> getPhonePages() {
      return [
        _buttonCRUDPhone(),
        _questionCRUDPhone(),
      ];
    }
    _phonePages = getPhonePages();
    _tabletPages = getTabletPages();
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
                                cancelAll();
                                _selectedIndex = value;
                              });
                            },
                            tabs: [
                              CupertinoFloatingTab(child: Text('Department', style: GoogleFonts.poppins(fontSize: ResponsiveValue<double>(context, 
                                  defaultValue: 18.0, 
                                  conditionalValues: [
                                    Condition.smallerThan(name: TABLET, value: 10.0),
                                    Condition.largerThan(name: TABLET, value: 16.0),
                                  ],
                                ).value,),)),
                              CupertinoFloatingTab(child: Text('Questions', style: GoogleFonts.poppins(fontSize: ResponsiveValue<double>(context, 
                                  defaultValue: 18.0, 
                                  conditionalValues: [
                                    Condition.smallerThan(name: TABLET, value: 10.0),
                                    Condition.largerThan(name: TABLET, value: 16.0),
                                  ],
                                ).value,),)),
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
      body: buildPage()
    );
  }

  Widget _buttonCRUDDesktop() {
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
                                      _isEditingDepartment || _isAddingDepartment ? print("None") :
                                      setState(() {
                                        _selectedDepartment = index;
                                        _fetchDepartments();
                                      });
                                    },
                                  );
                                },
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
                        ? buttonCard(context, _departments, _selectedDepartment, _isAddingDepartment, _isEditingDepartment, departmentNameController, _selectedIcon, 
                            (String newIcon) {
                              setState(() {
                                _selectedIcon = newIcon;
                              });
                            },
                          ) 
                        : 
                        buttonCard(context,_departments, 0, _isAddingDepartment, _isEditingDepartment, departmentNameController, _selectedIcon, 
                            (String newIcon) {
                              setState(() {
                                _selectedIcon = newIcon;
                              });
                            },
                          ),
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
  Widget _buttonCRUDTablet() {
    return SingleChildScrollView(
      child: Card(
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
                    'Department',
                    style: GoogleFonts.poppins(fontSize: 20, color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                  ),
                  _isAddingDepartment || _isEditingDepartment ?
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isAddingDepartment = false;
                          _isEditingDepartment = false;
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
                  _departments.isEmpty ? Text("") :
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 70),
              height: 300,
              child:                   
                _selectedDepartment != 0 
                  ? buttonCard(context,_departments, _selectedDepartment, _isAddingDepartment, _isEditingDepartment, departmentNameController, _selectedIcon, 
                      (String newIcon) {
                        setState(() {
                          _selectedIcon = newIcon;
                        });
                      },
                    )  
                  : buttonCard(context,_departments, 0, _isAddingDepartment, _isEditingDepartment, departmentNameController, _selectedIcon, 
                      (String newIcon) {
                        setState(() {
                          _selectedIcon = newIcon;
                        });
                      },
                    )
            ),
            SizedBox(height: 10,),
            _isAddingDepartment || _isEditingDepartment ?
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
              height: 40,
              child: SizedBox(
                width: 70,
                child: 
                ElevatedButton(
                  onPressed: () => setState(() {
                    _isAddingDepartment = true;
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
            SizedBox(
              width: double.infinity,
              height: 480,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: _departments.length,
                itemBuilder: (context, index) {
                  return _listCard("department",index);
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
  Widget _buttonCRUDPhone() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Department',
                    style: GoogleFonts.poppins(fontSize: 15, color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
                  ),
                  _isAddingDepartment || _isEditingDepartment ?
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isAddingDepartment = false;
                          _isEditingDepartment = false;
                        }),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.xCircle,
                              color: const Color.fromARGB(255, 156, 20, 20),
                              size: 10,
                            ),
                            SizedBox(width: 1),
                            Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
                                color: const Color.fromARGB(255, 156, 20, 20)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  )
                  : 
                  _departments.isEmpty ? Text("") :
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
                              size: 10,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "Delete",
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
                                color: Color.fromARGB(255, 144, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4,),
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
                              size: 10,
                            ),
                            SizedBox(width: 2),
                            Text(
                              "Edit",
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
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
              padding: EdgeInsets.symmetric(horizontal: 1),
              height: 200,
              child:                   
                _selectedDepartment != 0 
                  ? buttonCard(context,_departments, _selectedDepartment, _isAddingDepartment, _isEditingDepartment, departmentNameController, _selectedIcon, 
                            (String newIcon) {
                              setState(() {
                                _selectedIcon = newIcon;
                              });
                            },
                          ) 
                  : buttonCard(context,_departments, 0, _isAddingDepartment, _isEditingDepartment, departmentNameController, _selectedIcon, 
                            (String newIcon) {
                              setState(() {
                                _selectedIcon = newIcon;
                              });
                            },
                          )
            ),
            SizedBox(height: 10,),
            _isAddingDepartment || _isEditingDepartment ?
            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  bool? confirmAdd = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:  Text(_isAddingDepartment ? "Adding Department":"Editing "+_departments[_selectedDepartment]["button_name"]+ " Department", style: GoogleFonts.poppins(fontSize: 10),),
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
              height: 40,
              child: SizedBox(
                width: 70,
                child: 
                ElevatedButton(
                  onPressed: () => setState(() {
                    _isAddingDepartment = true;
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
                width: double.infinity,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _departments.length,
                  itemBuilder: (context, index) {
                    return _listCard("department",index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _questionCRUDPhone() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // color: Colors.blue,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      'Survey Questionaires',
                      style: GoogleFonts.poppins(fontSize: 13, color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),softWrap: true
                    ),
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
                              size: 10,
                            ),
                            SizedBox(width: 1),
                            Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
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
                              size: 10,
                            ),
                            SizedBox(width: 1),
                            Text(
                              "Delete",
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
                                color: Color.fromARGB(255, 144, 0, 0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5,),
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
                              size: 10,
                            ),
                            SizedBox(width: 1),
                            Text(
                              "Edit",
                              style: GoogleFonts.poppins(
                                fontSize: 10, 
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
              padding: EdgeInsets.symmetric(horizontal: 5),
              height: 200,
              child: questionCard(context, filteredQuestions,_isAddingQuestion,_isEditingQuestion,_selectedQuestion,_questionController)
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
                      size: 10,
                    ),
                    SizedBox(width: 2),
                    Text(
                      "Save",
                      style: GoogleFonts.poppins(
                        fontSize: 10, 
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
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: _departments.isEmpty
                ? Text("None")
                : DropdownButton<String>(
                    value: _selectedDepartmentInQuestion == -1
                        ? "General Question"
                        : _departments[_selectedDepartmentInQuestion]["button_name"],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedQuestion = 0;
                          if (newValue == "General Question") {
                            _selectedDepartmentInQuestion = -1;
                          } else {
                            _selectedDepartmentInQuestion = _departments.indexWhere(
                              (dept) => dept["button_name"] == newValue,
                            );
                          }
                          filterQuestionsByDepartment(); 
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: "General Question",
                        child: Text(
                          "General Question",
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                      ..._departments.map((dept) {
                        return DropdownMenuItem(
                          value: dept["button_name"].toString(),
                          child: Text(
                            dept["button_name"].toString(),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    return _listCard("question",index);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  

  
  Widget _questionCRUDTablet() {
    return SingleChildScrollView(
      child: Card(
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
                      style: GoogleFonts.poppins(fontSize: 20, color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
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
                child: questionCard(context, filteredQuestions,_isAddingQuestion,_isEditingQuestion,_selectedQuestion,_questionController)
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
              Container(
                width: 300,
                padding: EdgeInsets.all(10),
                child:  _departments.isEmpty
                  ? Text("")
                  : DropdownButton<String>(
                      value: _selectedDepartmentInQuestion == -1
                          ? "General Question"
                          : _departments[_selectedDepartmentInQuestion]["button_name"],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedQuestion = 0;
                            if (newValue == "General Question") {
                              _selectedDepartmentInQuestion = -1;
                            } else {
                              _selectedDepartmentInQuestion = _departments.indexWhere(
                                (dept) => dept["button_name"] == newValue,
                              );
                            }
                            filterQuestionsByDepartment(); // if you're using the filter function
                          });
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: "General Question",
                          child: Text(
                            "General Question",
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                          ),
                        ),
                        ..._departments.map((dept) {
                          return DropdownMenuItem(
                            value: dept["button_name"].toString(),
                            child: Text(
                              dept["button_name"].toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              softWrap: true,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
              ),
              SizedBox(height: 10,),
              
              SizedBox(
                width: double.infinity,
                height: 480,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    return _listCard("question",index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _questionCRUDDesktop() {
    return  Card(
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
                    'Survey Questionaires',
                    style: GoogleFonts.poppins(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0)
                    ),
                  ),
                  _isAddingQuestion || _isEditingQuestion ?
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _isAddingQuestion = false;
                          _isEditingQuestion = false;
                          _questionController.clear();
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
                  : _questions.isEmpty ? Text("") :
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
                      // ElevatedButton(
                      //   onPressed: () => setState(() {
                      //     print("Selected Question: $_selectedQuestion");
                      //     print("filtered Question $filteredQuestions");
                      //     print("Questions: $_questions");
                      //     print("Selected Question ${filteredQuestions[_selectedQuestion]}");
                      //   }),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Icon(
                      //         LucideIcons.infinity,
                      //         color: const Color.fromARGB(255, 0, 0, 0),
                      //         size: 15,
                      //       ),
                      //       SizedBox(width: 2),
                      //       Text(
                      //         "Test",
                      //         style: GoogleFonts.poppins(
                      //           fontSize: 15, 
                      //           color: const Color.fromARGB(255, 0, 0, 0)
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
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
                  child: Card(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: _departments.isEmpty
                            ? Text("None")
                            : DropdownButton<String>(
                                value: _selectedDepartmentInQuestion == -1
                                    ? "General Question"
                                    : _departments[_selectedDepartmentInQuestion]["button_name"],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedQuestion = 0;
                                      if (newValue == "General Question") {
                                        _selectedDepartmentInQuestion = -1;
                                      } else {
                                        _selectedDepartmentInQuestion = _departments.indexWhere(
                                          (dept) => dept["button_name"] == newValue,
                                        );
                                      }
                                      filterQuestionsByDepartment(); 
                                    });
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                    value: "General Question",
                                    child: Text(
                                      "General Question",
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      softWrap: true,
                                    ),
                                  ),
                                  ..._departments.map((dept) {
                                    return DropdownMenuItem(
                                      value: dept["button_name"].toString(),
                                      child: Text(
                                        dept["button_name"].toString(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true,
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                        ),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            itemCount: filteredQuestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text("Question ${index+1}",),
                                onTap: () {
                                  _isEditingQuestion || _isAddingQuestion ? print("None") :
                                  setState(() {
                                    _selectedQuestion = index;
                                    _fetchQuestions();
                                  });
                                },
                              );
                            },
                          ),
                        ),
              
                      ],
                    )
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [                      
                      _selectedQuestion != 0 
                        ? questionCard(context, filteredQuestions,_isAddingQuestion,_isEditingQuestion,_selectedQuestion,_questionController)
                        : questionCard(context, filteredQuestions,_isAddingQuestion,_isEditingQuestion,_selectedQuestion,_questionController),
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
                                  title: _isAddingQuestion? Text("Adding Question") :Text("Editing Question "+_selectedQuestion.toString()),
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
                              _fetchQuestions();
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
                             _isAddingQuestion = true;
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
  Widget _listCard(String type, int id) {
    int departmentID = 0;
    int questionID = 0;
    type == "question" ? questionID = id : departmentID = id;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          _isEditingQuestion || _isEditingDepartment || _isAddingQuestion || _isAddingDepartment ? print("None") :
          setState(() {
            _selectedQuestion = questionID;
            _selectedDepartment = departmentID;
            _fetchDepartments();
            _fetchQuestions();
          });
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            return Container(
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
                      type == "question" ? "Question ${questionID+1} " : _departments[departmentID]["button_name"],
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.09, 
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
            );
          }
        )
      )
    );
  }
}
