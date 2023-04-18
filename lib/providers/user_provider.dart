import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    email: '',
    token: '',
    password: '',
  );

  User get user => _user;

  Future<void> setUser(String user) async {
    _user = User.fromJson(user);
    notifyListeners();
  }

  Future<void> setUserFromModel(User user) async{
    _user = user;
    notifyListeners();
  }
}