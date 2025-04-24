
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../authentication/login.dart';
import '../../statistics/statistics.dart';
import '../../settings/settings.dart';
import '../../feedback/feedback.dart';
// import '../../test.dart';

void logout(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
}

void goToStatistics(context){
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => StatisticsPage())
  );
}
void goToCustomerFeedBack(context, buttonId) {
  
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => CustomerFeedback(buttonId: buttonId,))
  );
}
void goToSettings(context){
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SettingsPage())
  );
}
// void goToTest(context){
//   Navigator.pushReplacement(
//     context,
//     MaterialPageRoute(builder: (context) => BarChartSample2())
//   );
// }