import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';
import '../screens/home_screen.dart';
import '../screens/signup_screen.dart';
import '../utils/constants.dart';
import '../utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<void> signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    User user = User(
      id: '',
      name: name,
      password: password,
      email: email,
      token: '',
    );

    try {
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      httpErrorHandle(
        response: res,
        onSuccess: () {
          showSnackBarMessage(
            context,
            'Account created! Login with the same credentials!',
          );
        },
        onError: (error) {
          showSnackBarMessage(context, error);
        },
      );
    } catch (e) {

      showSnackBarMessage(context, e.toString());
    } finally {
      // Perform any cleanup here if required
    }
  }

  Future<void> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);

    final navigator = Navigator.of(context);
    try {
      final response = await http.post(
        Uri.parse('${Constants.uri}/api/signing'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: response,
        onSuccess: () async {
          final prefs = await SharedPreferences.getInstance();

          userProvider.setUser(response.body);
          await prefs.setString('x-auth-token', jsonDecode(response.body)['token']);
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
        },
        onError: (error) {
          showSnackBarMessage(context, error);
        },
      );
    } catch (e) {
      showSnackBarMessage(context, e.toString());
    }
  }

//get user data

  Future<void> getUserData(BuildContext context) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        token = '';
        prefs.setString('x-auth-token', '');
      }

      final tokenRes = await http.post(
        Uri.parse('${Constants.uri}/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      final response = jsonDecode(tokenRes.body);

      if (response == true) {
        final userRes = await http.get(
          Uri.parse('${Constants.uri}/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'x-auth-token': token!,
          },
        );

        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBarMessage(context, e.toString());
    }
  }



  Future<void> signOut(BuildContext context) async {
    final navigator = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', '');

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignupScreen()),
          (route) => false,
    );
  }

}