import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:recipe_management_app/model/recipe.dart';
import 'package:recipe_management_app/model/user.dart';
import 'package:recipe_management_app/screen/add_recipe.dart';
import 'package:recipe_management_app/screen/admin_page.dart';
import 'package:recipe_management_app/screen/login_page.dart';
import 'package:recipe_management_app/screen/recipe_details_page.dart';
import 'package:recipe_management_app/screen/recipe_list_page.dart';
import 'package:recipe_management_app/viewmodel/auth_viewmodel.dart';
import 'package:recipe_management_app/viewmodel/login_viewmodel.dart';
import 'package:recipe_management_app/viewmodel/recipe_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(RecipeAdapter());
  await Hive.openBox('usersBox');
  await Hive.openBox('recipesBox');

  addDummyUsers();

  runApp(const MyApp());
}

void addDummyUsers() {
  final usersBox = Hive.box('usersBox');

  if (usersBox.isEmpty) {
    usersBox.add(User(
      username: 'admin',
      password: 'admin123',
      isAdmin: true,
    ));

    usersBox.add(User(
      username: 'user',
      password: 'user123',
      isAdmin: false,
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationViewModel()),
        ChangeNotifierProvider(create: (_) => RecipeViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: Consumer<LoginViewModel>(
        builder: (context, authViewModel, child) {
          return FutureBuilder<bool>(
            future: authViewModel.checkSession(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  snapshot.hasData == false) {
                return const Material(
                    child: Center(
                  child: CircularProgressIndicator(),
                ));
              }
              if (snapshot.data == true) {
                if (authViewModel.isAdmin) {
                  return MaterialApp(
                    home: const AdminPage(),
                    routes: {
                      '/login': (context) => LoginScreen(),
                      '/admin': (context) => const AdminPage(),
                      '/recipes': (context) => const RecipeListScreen(),
                      '/addRecipe': (context) => const AddRecipePage(),
                    },
                  );
                } else {
                  return MaterialApp(
                    home: const RecipeListScreen(),
                    routes: {
                      '/login': (context) => LoginScreen(),
                      '/admin': (context) => const AdminPage(),
                      '/recipes': (context) => const RecipeListScreen(),
                      '/addRecipe': (context) => const AddRecipePage(),
                      '/recipeDetails': (context) => RecipeDetailsPage(
                            recipe: ModalRoute.of(context)!.settings.arguments
                                as Recipe,
                          )
                    },
                  );
                }
              }

              return MaterialApp(
                home: LoginScreen(),
                routes: {
                  '/login': (context) => LoginScreen(),
                  '/admin': (context) => const AdminPage(),
                  '/recipes': (context) => const RecipeListScreen(),
                  '/addRecipe': (context) => const AddRecipePage(),
                  '/recipeDetails': (context) => RecipeDetailsPage(
                        recipe: ModalRoute.of(context)!.settings.arguments
                            as Recipe,
                      )
                },
              );
            },
          );
        },
      ),
    );
  }
}
