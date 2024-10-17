import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recipe_management_app/model/user.dart';

class AuthenticationViewModel extends ChangeNotifier {
  final FlutterSecureStorage secureStorage = const  FlutterSecureStorage();
  User? _currentUser;
  bool _isAdmin = false;

  User? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;

  // Function to log in a user
  Future<bool> login(String username, String password) async {
    final usersBox = Hive.box('usersBox');
    final user = usersBox.values.cast<User>().firstWhere(
          (user) => user.username == username && user.password == password,
      orElse: () => throw 'Oops',
    );

    if (user != null) {
      _currentUser = user;
      _isAdmin = user.isAdmin;

      // Save user session in secure storage
      await secureStorage.write(key: 'username', value: username);
      notifyListeners();
      return true;
    } else {
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  // Function to check if there is a logged-in user in secure storage
  Future<bool> checkSession() async {
    final username = await secureStorage.read(key: 'username');
    if (username != null) {
      final usersBox = Hive.box('usersBox');
      final user = usersBox.values.cast<User>().firstWhere(
        (user) => user.username == username,
        orElse: () => throw 'Oops',
      );
      if (user != null) {
        _currentUser = user;
        _isAdmin = user.isAdmin;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Function to log out the user
  Future<void> logout() async {
    await secureStorage.delete(key: 'username');
    _currentUser = null;
    _isAdmin = false;
    notifyListeners();
  }
}
