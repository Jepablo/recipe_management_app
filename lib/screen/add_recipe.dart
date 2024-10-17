// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:recipe_management_app/model/recipe.dart';
import 'package:recipe_management_app/utils/json_loader.dart';
import 'package:recipe_management_app/viewmodel/recipe_viewmodel.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _titleController = TextEditingController();
  File? _imageFile;
  final _imagePicker = ImagePicker();

  final List<String> _ingredients = [];
  final List<String> _steps = [];
  List<dynamic> _recipeTypes = [];
  String? _selectedRecipeType;
  final _ingredientController = TextEditingController();
  final _stepController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecipeTypes();
  }

  Future<void> _loadRecipeTypes() async {
    final types = await loadRecipeTypes();
    setState(() {
      _recipeTypes = types;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _addStep() {
    if (_stepController.text.isNotEmpty) {
      setState(() {
        _steps.add(_stepController.text);
        _stepController.clear();
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_titleController.text.isEmpty ||
        _selectedRecipeType == null ||
        _imageFile == null ||
        _ingredients.isEmpty ||
        _steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all fields and add an image.')));
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await _imageFile!.copy(imagePath);

    final newRecipe = Recipe(
      title: _titleController.text,
      type: _selectedRecipeType!,
      imagePath: savedImage.path,
      ingredients: _ingredients,
      steps: _steps,
    );

    // final recipeBox = Hive.box('recipesBox');
    // await recipeBox.add(newRecipe);

    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    recipeViewModel.addRecipe(newRecipe);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe added successfully!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Recipe")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Recipe Title'),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: _selectedRecipeType,
                hint: const Text('Select Recipe Type'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRecipeType = newValue;
                  });
                },
                items: _recipeTypes
                    .map<DropdownMenuItem<String>>((dynamic value) {
                  return DropdownMenuItem<String>(
                    value: value as String,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: _pickImage,
              child: _imageFile == null
                  ? Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.add_a_photo, size: 50),
                    )
                  : Image.file(
                      _imageFile!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _ingredientController,
              decoration: const InputDecoration(labelText: 'Add Ingredient'),
              onSubmitted: (value) => _addIngredient(),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
                onPressed: _addIngredient, child: const Text('Add Ingredient')),
            const SizedBox(height: 16.0),
            const Text('Ingredients:'),
            ..._ingredients.map((ingredient) => ListTile(title: Text(ingredient))),
            const SizedBox(height: 16.0),
            TextField(
              controller: _stepController,
              decoration: const InputDecoration(labelText: 'Add Step'),
              onSubmitted: (value) => _addStep(),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(onPressed: _addStep, child: const Text('Add Step')),
            const SizedBox(height: 16.0),
            const Text('Steps:'),
            ..._steps.map((step) => ListTile(title: Text(step))),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveRecipe,
              child: const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
