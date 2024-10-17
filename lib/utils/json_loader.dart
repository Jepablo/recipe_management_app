import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<String>> loadRecipeTypes() async {
  final String response = await rootBundle.loadString('lib/asset/recipe_types.json');
  final List<dynamic> data = json.decode(response);

  return data.map((item) => item['name'] as String).toList();
}
