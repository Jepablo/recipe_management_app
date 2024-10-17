import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 1)
class Recipe {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String type;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final List<String> ingredients;

  @HiveField(4)
  final List<String> steps;

  Recipe({required this.title, required this.type, required this.imagePath, required this.ingredients, required this.steps});
}
