// lib/blocs/recipe/models/recipe_validation_result.dart
class RecipeValidationResult {
  final bool isValid;
  final List<String> errors;

  const RecipeValidationResult({
    required this.isValid,
    required this.errors,
  });
}