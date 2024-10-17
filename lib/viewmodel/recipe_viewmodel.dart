import 'package:flutter/material.dart';
import 'package:recipe_management_app/model/recipe.dart';
import 'package:hive/hive.dart';

class RecipeViewModel extends ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> _filteredRecipes = [];
  String? _selectedType;
  final List<String> recipeTypes = ['All', 'Dessert', 'Main Course', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Appetizer'];

  RecipeViewModel() {
    _loadRecipes();
  }

  List<Recipe> get recipes => _selectedType == null || _selectedType == 'All' 
      ? _recipes 
      : _filteredRecipes;

  String? get selectedType => _selectedType;

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    if (_selectedType == null || _selectedType == recipe.type || _selectedType == 'All') {
      _filteredRecipes.add(recipe);  
    }
    notifyListeners();
  }

  Future<void> _loadRecipes() async {
    final recipeBox = await Hive.openBox('recipesBox');
    _recipes = recipeBox.values.cast<Recipe>().toList();
    filterRecipesByType(_selectedType); 
    notifyListeners();
  }

  void filterRecipesByType(String? type) {
    _selectedType = type;
    if (_selectedType == 'All' || _selectedType == null) {
      _filteredRecipes = _recipes;  
    } else {
      _filteredRecipes = _recipes.where((recipe) => recipe.type == _selectedType).toList();
    }
    notifyListeners();  
  }
}
