import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nodejs/providers/user_provider.dart';
import 'package:nodejs/screens/home_screen.dart';
import 'package:nodejs/screens/signup_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';

class AuthService {

  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user =
          User(id: '', name: name, password: password, email: email, token: '');
      http.Response res = await http.post(
          Uri.parse('http://192.168.137.1/api/signup'),
          body: user.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Account Created");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signInUser(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
          Uri.parse('http://192.168.137.1/api/signin'),
          body: jsonEncode(
            {'email': email, 'password': password},
          ),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          });
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProvider.setUser(res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false);
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(
        'x-auth-token',
      );

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }

      var tokenRes = await http.post(Uri.parse('http://192.168.137.1/tokenIsValid'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token!
          });

      var response = jsonDecode(tokenRes.body);
      if (response == true) {
        http.Response userRes = await http.get(
            Uri.parse('http://192.168.137.1/tokenIsValid'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'x-auth-token': token
            });
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', '');
    navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignupScreen()),
        (route) => false);
  }
}
