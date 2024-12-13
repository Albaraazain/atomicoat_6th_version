import 'package:experiment_planner/blocs/recipe/models/recipe_validation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecipeValidationResult', () {
    test('creates valid result', () {
      final result = RecipeValidationResult(
        isValid: true,
        errors: [],
      );
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('creates invalid result with errors', () {
      final result = RecipeValidationResult(
        isValid: false,
        errors: ['Error 1', 'Error 2'],
      );
      expect(result.isValid, false);
      expect(result.errors, hasLength(2));
      expect(result.errors, contains('Error 1'));
      expect(result.errors, contains('Error 2'));
    });
  });
}
