import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recipe_management_app/model/user.dart';

class LoginViewModel extends ChangeNotifier {
  final FlutterSecureStorage secureStorage = const  FlutterSecureStorage();
  String? errorMessage;
  User? _currentUser;
  bool _isAdmin = false;

  User? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool login(String username, String password) {
    final usersBox = Hive.box('usersBox');

    User? user = usersBox.values.cast<User>().firstWhere(
          (user) => user.username == username && user.password == password,
          orElse: () => throw 'Oops',
        );

    if (user != null) {
      _currentUser = user;
      _isAdmin = user.isAdmin;

      secureStorage.write(key: 'username', value: username);
      secureStorage.write(
          key: 'isAdmin', value: user.isAdmin.toString());
      errorMessage = null;
      notifyListeners();
      return true;
    } else {
      // Invalid credentials
      errorMessage = 'Invalid username or password';
      notifyListeners();
      return false;
    }
  }


  Future<bool> isAdmin1() async {
    final isAdminValue = await secureStorage.read(key: 'isAdmin');
    return isAdminValue == 'true';
  }

  Future<bool> checkSession() async {
    try {

      final username = await secureStorage.read(key: 'username');

      if (username != null) {
        final usersBox = Hive.box('usersBox');

        final List<User> matchedUsers = usersBox.values
            .cast<User>()
            .where(
              (user) => user.username == username,
            )
            .toList();

        if (matchedUsers.isNotEmpty) {
          final User user = matchedUsers.first;
          _currentUser = user;
          _isAdmin = user.isAdmin;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('Error in checkSession: $e');
    }

    print('No valid session found.');
    return false;
  }

  Future<void> logout(BuildContext context) async {
    await secureStorage.delete(key: 'username');
    await secureStorage.delete(key: 'isAdmin');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    notifyListeners();
  }
}
