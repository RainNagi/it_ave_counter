import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepository {
  final String ip = dotenv.get('IP_ADDRESS');

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("http://$ip/kpi_itave/auth-handler.php");
    try {
      final response = await http.post(url, body: {
        "action": "login",
        "email": email,
        "password": password,
      });

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to login: ${response.statusCode}");
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

   Future<Map<String, dynamic>> registerUser(String uname, String email, String password) async {
    var url = Uri.parse("http://$ip/kpi_itave/auth-handler.php");
    var response = await http.post(url, body: {
      "action": "register",
      "uname": uname,
      "email": email,
      "password": password,
    });

    return jsonDecode(response.body);
  }
}
