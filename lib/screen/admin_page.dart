import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:recipe_management_app/model/user.dart';
import 'package:recipe_management_app/viewmodel/login_viewmodel.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<User> users = [];
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Load the list of users from Hive
  void _loadUsers() {
    final box = Hive.box('usersBox');
    setState(() {
      users = box.values.cast<User>().toList(); // Retrieve all users
    });
  }

  void _addUser() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final newUser = User(
      username: _usernameController.text,
      password: _passwordController.text,
      isAdmin: _isAdmin,
    );

    final box = Hive.box('usersBox');

    box.add(newUser);

    _usernameController.clear();
    _passwordController.clear();
    _isAdmin = false;

    _loadUsers();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User added successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Page"),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Provider.of<LoginViewModel>(context, listen: false)
                    .logout(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8.0),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8.0),

            CheckboxListTile(
              title: const Text('Is Admin'),
              value: _isAdmin,
              onChanged: (newValue) {
                setState(() {
                  _isAdmin = newValue ?? false;
                });
              },
            ),

            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: _addUser,
              child: const Text('Add User'),
            ),

            const SizedBox(height: 24.0),

            const Text(
              'User List',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.username),
                    subtitle: Text(user.isAdmin ? 'Admin' : 'Normal User'),
                    trailing: Icon(user.isAdmin ? Icons.shield : Icons.person),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: () {
                Provider.of<LoginViewModel>(context, listen: false)
                    .logout(context);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
