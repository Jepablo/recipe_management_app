import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_management_app/viewmodel/login_viewmodel.dart';

class LoginScreen extends StatelessWidget {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: const Key('usernameField'),
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              key: const Key('passwordField'),
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              key: const Key('loginButton'),
              onPressed: () async {
                final username = _usernameController.text;
                final password = _passwordController.text;

                bool success = loginViewModel.login(username, password);

                if (success) {
                  bool isAdmin = await loginViewModel.isAdmin1();
                  if (isAdmin) {
                    Navigator.pushReplacementNamed(context, '/admin');
                  } else {
                    Navigator.pushReplacementNamed(context, '/recipes');
                  }
                }
              },
              child: const Text('Login'),
            ),
            if (loginViewModel.errorMessage != null)
              Text(
                loginViewModel.errorMessage!,
                key: const Key('errorMessage'),
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
