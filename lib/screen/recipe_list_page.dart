import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_management_app/viewmodel/login_viewmodel.dart';
import 'package:recipe_management_app/viewmodel/recipe_viewmodel.dart';

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Scaffold(
      floatingActionButton: IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () {
          Provider.of<LoginViewModel>(context, listen: false).logout(context);
        },
      ),
      appBar: AppBar(
        title:const Text('Recipes'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/addRecipe');
              },
              child: const Text('Add Recipe'))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: recipeViewModel.selectedType ?? 'All',
              onChanged: (String? newValue) {
                recipeViewModel.filterRecipesByType(newValue);
              },
              items: recipeViewModel.recipeTypes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recipeViewModel.recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipeViewModel.recipes[index];
                return ListTile(
                  title: Text(recipe.title),
                  subtitle: Text(recipe.type),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/recipeDetails',
                      arguments: recipe,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
