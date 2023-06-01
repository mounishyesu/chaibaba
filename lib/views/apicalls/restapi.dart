import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class URLS {
  static const String BASE_URL = 'https://smark.org.in/chaibaba';
}

class ApiService {

  static Future post(url, body) async {
    try {
      final response = await http.post(Uri.parse('${URLS.BASE_URL}/${url}'),
          headers: {
            "Content-type": "application/x-www-form-urlencoded",
          },
          body: body);
      print(HttpHeaders.requestHeaders);
      print('${URLS.BASE_URL}/${url}');
      print(response.statusCode);
      return response;
    } catch (e) {
      return e;
    }
  }

  static Future get(url) async {
    try {
      final response = await http.get(Uri.parse('${URLS.BASE_URL}/${url}'),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer "
          });
      print(HttpHeaders.requestHeaders);
      print('${URLS.BASE_URL}/${url}');
      print(response.statusCode);
      return response;
    } catch (e) {
      return e;
    }
  }
}
