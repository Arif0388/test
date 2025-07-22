// ignore_for_file: use_build_context_synchronously

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:learningx_flutter_app/Screens/auth/activate_account.dart';
import 'package:learningx_flutter_app/Screens/auth/reset_password.dart';
import 'package:learningx_flutter_app/Screens/auth/signup_verification.dart';
import 'package:learningx_flutter_app/Screens/college/college_selection_search.dart';
import 'package:learningx_flutter_app/api/model/user_modal.dart';
import 'package:learningx_flutter_app/api/provider/extra_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider {
  var url = dotenv.env['BASE_API_URL'];

  Future<bool> checkRequiredUpdate(BuildContext context) async {
    var platform = "web";
    int version = 1;
    if (!kIsWeb && Platform.isAndroid) {
      platform = "android";
      version = 45;
    } else if (!kIsWeb && Platform.isIOS) {
      platform = "ios";
      version = 25;
    }
    final response = await http.get(
      Uri.parse("$url/users/apps/update?platform=$platform"),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (version < jsonResponse['requiredVersion']) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> checkTokenValidity(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    if (token == null) {
      return false; // No token found
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return false; // Invalid token format
      }

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'];

      if (exp == null) {
        return false; // No expiration field in token
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return expiryDate
          .isAfter(DateTime.now()); // Check if the token is still valid
    } catch (e) {
      return false; // Error while decoding
    }
  }

  Future<void> loginUser(BuildContext context, Map<String, String> map) async {
    final response = await http.post(
      Uri.parse("$url/users/login"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(map),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        if (data['status'] == "OTP sent successfully!") {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VerificationActivity(user: data['user']),
            ),
          );
        } else {
          Map<String, dynamic> userJson = data['user'];

          String? college;
          if (userJson.containsKey('college')) {
            if (userJson['college'] != null) {
              String collegeValue = userJson['college'];
              if (collegeValue.isNotEmpty) {
                college = collegeValue;
              }
            }
          }

          User user = User(
            id: userJson['_id'],
            token: data['token'],
            username: userJson['username'],
            userNameId: userJson['user_name'],
            googleId: userJson['googleId'],
            userImg: userJson['userImg'],
            firstname: userJson['firstname'],
            lastname: userJson['lastname'],
            displayName: userJson['displayName'],
            verified: userJson['admin'],
            college: college,
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('id', user.id);
          await prefs.setString('token', user.token ?? "");
          await prefs.setString('username', user.username);
          await prefs.setString('user_name', user.userNameId);
          await prefs.setString('googleId', user.googleId);
          await prefs.setString('userImg', user.userImg);
          await prefs.setString('firstname', user.firstname);
          await prefs.setString('lastname', user.lastname);
          await prefs.setString('displayName', user.displayName);
          await prefs.setString('college', user.college ?? "");
          if (userJson.containsKey('azureId')) {
            await prefs.setString('azureId', userJson['azureId']);
          }

          if (userJson.containsKey('deactivated')) {
            var deactivated = userJson['deactivated'];
            if (deactivated) {
              await prefs.setBool('isLoggedIn', false);
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ActivateAccount(
                          id: user.id,
                        )),
              );
              return;
            }
          }
          await prefs.setBool('isLoggedIn', true);
          await logUserActivityApi(context, {
            'activityType': "login",
            'college': college,
            'platform': map['platform']
          });
          context.go("/home");
        }
      }
    } else {
      final error = json.decode(response.body);
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }

  Future<void> googleUserSignIn(
      BuildContext context, Map<String, String> map) async {
    final response = await http.post(
      Uri.parse("$url/users/google/${map['url']}"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(map),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        Map<String, dynamic> userJson = data['user'];

        String? college;
        if (userJson.containsKey('college')) {
          String collegeValue = userJson['college'];
          if (collegeValue.isNotEmpty && collegeValue != "null") {
            college = collegeValue;
          }
        }

        User user = User(
          id: userJson['_id'],
          token: data['token'],
          username: userJson['username'],
          userNameId: userJson['user_name'],
          googleId: userJson['googleId'],
          userImg: userJson['userImg'],
          firstname: userJson['firstname'],
          lastname: userJson['lastname'],
          displayName: userJson['displayName'],
          verified: userJson['admin'],
          college: college,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', user.id);
        await prefs.setString('token', user.token ?? "");
        await prefs.setString('username', user.username);
        await prefs.setString('user_name', user.userNameId);
        await prefs.setString('googleId', user.googleId);
        await prefs.setString('userImg', user.userImg);
        await prefs.setString('firstname', user.firstname);
        await prefs.setString('lastname', user.lastname);
        await prefs.setString('displayName', user.displayName);
        await prefs.setString('college', user.college ?? "");
        await prefs.setBool('isLoggedIn', true);
        if (userJson.containsKey('azureId')) {
          await prefs.setString('azureId', userJson['azureId']);
        }

        if (data['newUser']) {
          Map<String, dynamic> map = HashMap();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollegeSelectionWidget(map: map),
            ),
          );
        } else {
          await logUserActivityApi(context, {
            'activityType': "login",
            'college': college,
            'platform': map['platform']
          });
          context.go("/home");
        }
      }
    } else {
      final error = json.decode(response.body);
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }

  Future<void> azureUserSignIn(
      BuildContext context, Map<String, String> map) async {
    final response = await http.post(
      Uri.parse("$url/users/azure/login"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(map),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        Map<String, dynamic> userJson = data['user'];

        String? college;
        if (userJson.containsKey('college')) {
          String collegeValue = userJson['college'];
          if (collegeValue.isNotEmpty && collegeValue != "null") {
            college = collegeValue;
          }
        }

        User user = User(
          id: userJson['_id'],
          token: data['token'],
          username: userJson['username'],
          userNameId: userJson['user_name'],
          googleId: userJson['azureId'],
          userImg: userJson['userImg'],
          firstname: userJson['firstname'],
          lastname: userJson['lastname'],
          displayName: userJson['displayName'],
          verified: userJson['admin'],
          college: college,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', user.id);
        await prefs.setString('token', user.token ?? "");
        await prefs.setString('username', user.username);
        await prefs.setString('user_name', user.userNameId);
        await prefs.setString('googleId', user.googleId);
        await prefs.setString('userImg', user.userImg);
        await prefs.setString('firstname', user.firstname);
        await prefs.setString('lastname', user.lastname);
        await prefs.setString('displayName', user.displayName);
        await prefs.setString('college', user.college ?? "");
        await prefs.setBool('isLoggedIn', true);
        if (userJson.containsKey('azureId')) {
          await prefs.setString('azureId', userJson['azureId']);
        }

        if (data['newUser']) {
          Map<String, dynamic> map = HashMap();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CollegeSelectionWidget(map: map),
            ),
          );
        } else {
          await logUserActivityApi(context, {
            'activityType': "login",
            'college': college,
            'platform': map['platform']
          });
          context.go("/home");
        }
      }
    } else {
      final error = json.decode(response.body);
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }

  void signUpUser(BuildContext context, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$url/users/signup"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerificationActivity(user: data['user']),
          ),
        );
      }
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }

  void validateOTPRequest(BuildContext context, Map<String, String> map) async {
    final response = await http.post(
      Uri.parse("$url/users/verification"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(map),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        Map<String, dynamic> userJson = data['user'];

        String? college;
        if (userJson.containsKey('college')) {
          String collegeValue = userJson['college'];
          if (collegeValue.isNotEmpty && collegeValue != "null") {
            college = collegeValue;
          }
        }

        User user = User(
          id: userJson['_id'],
          token: data['token'],
          username: userJson['username'],
          userNameId: userJson['user_name'],
          googleId: userJson['googleId'],
          userImg: userJson['userImg'],
          firstname: userJson['firstname'],
          lastname: userJson['lastname'],
          displayName: userJson['displayName'],
          verified: userJson['admin'],
          college: college,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', user.id);
        await prefs.setString('token', user.token ?? "");
        await prefs.setString('username', user.username);
        await prefs.setString('user_name', user.userNameId);
        await prefs.setString('googleId', user.googleId);
        await prefs.setString('userImg', user.userImg);
        await prefs.setString('firstname', user.firstname);
        await prefs.setString('lastname', user.lastname);
        await prefs.setString('displayName', user.displayName);
        await prefs.setString('college', user.college ?? "");
        await prefs.setBool('isLoggedIn', true);
        if (userJson.containsKey('azureId')) {
          await prefs.setString('azureId', userJson['azureId']);
        }
        await logUserActivityApi(context, {
          'activityType': "login",
          'college': college,
          'platform': map['platform']
        });
        context.go("/home");
      }
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }

  void resetPasswordRequest(
      BuildContext context, Map<String, String> data) async {
    final response = await http.post(
      Uri.parse("$url/users/reset-password"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(user: data['user']),
          ),
        );
      }
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }

  void resetPassword(BuildContext context, Map<String, String> data) async {
    final response = await http.post(
      Uri.parse("$url/users/reset-password/${data['token']}"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['status'])),
        );

        Map<String, dynamic> userJson = data['user'];

        String? college;
        if (userJson.containsKey('college')) {
          String collegeValue = userJson['college'];
          if (collegeValue.isNotEmpty && collegeValue != "null") {
            college = collegeValue;
          }
        }

        User user = User(
          id: userJson['_id'],
          token: data['token'],
          username: userJson['username'],
          userNameId: userJson['user_name'],
          googleId: userJson['googleId'],
          userImg: userJson['userImg'],
          firstname: userJson['firstname'],
          lastname: userJson['lastname'],
          displayName: userJson['displayName'],
          verified: userJson['admin'],
          college: college,
        );

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', user.id);
        await prefs.setString('token', user.token ?? "");
        await prefs.setString('username', user.username);
        await prefs.setString('user_name', user.userNameId);
        await prefs.setString('googleId', user.googleId);
        await prefs.setString('userImg', user.userImg);
        await prefs.setString('firstname', user.firstname);
        await prefs.setString('lastname', user.lastname);
        await prefs.setString('displayName', user.displayName);
        await prefs.setString('college', user.college ?? "");
        await prefs.setBool('isLoggedIn', true);
        if (userJson.containsKey('azureId')) {
          await prefs.setString('azureId', userJson['azureId']);
        }
        context.go("/home");
      }
    } else {
      final error = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error['err']['message']}')),
      );
    }
  }
}
