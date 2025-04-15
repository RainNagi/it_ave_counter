import 'package:flutter/material.dart';
import 'package:rating_and_feedback_collector/rating_and_feedback_collector.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '/../common/iconlist.dart';

final Map<String, IconData> _iconMap = IconDictionary.icons;
String _iconSearchQuery = '';


Widget questionCard(BuildContext context, List<dynamic> questions,bool isAddingQuestion, bool isEditingQuestion, int selectedQuestion,TextEditingController _questionController) {
  var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
  
  double questionTitleFont = screenType == MOBILE ? 0.05 : 0.037 ;
  double questionFont = screenType == MOBILE ? 0.046 : 0.03 ; 
  int num = questions.length + 1;
  double _rating = 2.5;
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Container(
      height: 350,
      width: double.infinity,
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
              width: double.infinity,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                questions.isEmpty ? "Questions 0" :
                                isAddingQuestion? "Question $num" : "Question $selectedQuestion",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * questionTitleFont,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.justify,
                                softWrap: true,
                              ),
                            ),
                            Container(width: 30, height: 2, color: Color.fromRGBO(111, 5, 6, 1)),
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
                                (isAddingQuestion || isEditingQuestion)
                                ? TextField(
                                    controller: _questionController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: "Enter question...",
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.028,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                  )
                                : Text(
                                    questions.isEmpty ? "There is no Question" : questions[selectedQuestion - 1]["question"],
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * questionFont,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                  ),
                                SizedBox(height: availableHeight * 0.05),
                                questions.isEmpty ? 
                                SizedBox(height: 30) :
                                RatingBar(
                                  iconSize: availableHeight * 0.2,
                                  allowHalfRating: true,
                                  filledIcon: Icons.star,
                                  halfFilledIcon: Icons.star_half,
                                  emptyIcon: Icons.star_border,
                                  filledColor: Colors.amber,
                                  emptyColor: Colors.grey,
                                  currentRating: _rating,
                                  onRatingChanged: (rating) {
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  );
                }
              )
            ),
          )
        ],
      ),
    ),
  );
}

Widget buttonCard(BuildContext context, List<dynamic> departments, int department, bool isAddingDepartment, bool isEditingDepartment, TextEditingController departmentNameController, String selectedIcon){
  var screenType = ResponsiveBreakpoints.of(context).breakpoint.name;
  
  double buttonTitleFont = screenType == MOBILE ? 0.05 : 0.037 ;
  double counterFont = screenType == MOBILE ? 0.046 : 0.03 ; 
  double visitorFont = screenType == MOBILE ? 0.02 : 0.015 ; 
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
                                    isAddingDepartment || isEditingDepartment
                                    ? SizedBox(
                                      width: 400,
                                      child: Column(
                                        children: [
                                          TextField(
                                            decoration: InputDecoration(labelText: isEditingDepartment ? departments[department]["button_name"] : "Department Name"),
                                            controller: departmentNameController,
                                          ),
                                          SizedBox(height: 10,),
                                        ],
                                      )
                                    )
                                    : Text(
                                        departments.isNotEmpty ? departments[department]["button_name"] : "Department",
                                        style: GoogleFonts.poppins(fontSize: screenWidth * buttonTitleFont, fontWeight: FontWeight.bold),
                                      ),
                                  Container(width: 40, height: 5, color: Color.fromRGBO(111, 5, 6, 1)),
                                ],
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.05),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                isAddingDepartment
                                ? 
                                Text("100",
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * counterFont, 
                                    color: Colors.black, 
                                    fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.center
                                ) :
                                Text(departments.isNotEmpty ? departments[department]['counter_count'].toString() : "100",
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * counterFont, 
                                    color: Colors.black, 
                                    fontWeight: FontWeight.bold
                                  ),
                                  textAlign: TextAlign.center
                                ),
                                Text('Visitors',
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * visitorFont,
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
                            double availableHeight = constraints.maxHeight; 
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: availableHeight * 0.1),
                                isAddingDepartment || isEditingDepartment?
                                GestureDetector(
                                  onTap:() {
                                    _showIconPickerDialog(context, selectedIcon);
                                  },
                                  child: Icon(
                                    selectedIcon == 'lucide_plus_circle' && isEditingDepartment ? IconDictionary.icons[departments[department]["button_icon"]] :_iconMap[selectedIcon],
                                    size: availableHeight * 0.5,
                                    color: Color.fromRGBO(151, 81, 2, 1),
                                  ),
                                ):
                                Icon(departments.isNotEmpty ? IconDictionary.icons[departments[department]["button_icon"]] : LucideIcons.plusCircle, size: availableHeight * 0.5, color: Color.fromRGBO(151, 81, 2, 1)), // Scale icon size
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
              isAddingDepartment || isEditingDepartment?
              Text("${departmentNameController.text} Visitor", style: GoogleFonts.poppins(fontSize: 10), textAlign: TextAlign.center)
              :
              Text(departments.isNotEmpty ? departments[department]["button_name"]+" Visitor": "Department Visitor", style: GoogleFonts.poppins(fontSize: 10), textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    ),
  );
}


void _showIconPickerDialog(BuildContext context, String selectedIcon) {
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
                            selectedIcon = iconName;
                          });
                          // _fetchDepartments();
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