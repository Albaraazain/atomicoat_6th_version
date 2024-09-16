import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/system_state_provider.dart';
import '../models/recipe.dart';

class RecipeControl extends StatelessWidget {
  const RecipeControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecipeProvider, SystemStateProvider>(
      builder: (context, recipeProvider, systemStateProvider, child) {
        return Opacity(
          opacity: 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecipeSelector(context, recipeProvider, systemStateProvider),
                SizedBox(height: 4),
                _buildRecipeControls(context, recipeProvider, systemStateProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeSelector(BuildContext context, RecipeProvider recipeProvider, SystemStateProvider systemStateProvider) {
    return Container(
      width: 150,
      child: DropdownButton<String>(
        isExpanded: true,
        value: systemStateProvider.selectedRecipe?.id,
        hint: Text('Select recipe', style: TextStyle(color: Colors.white70, fontSize: 12)),
        style: TextStyle(color: Colors.white, fontSize: 12),
        dropdownColor: Colors.black87,
        underline: Container(
          height: 1,
          color: Colors.white70,
        ),
        onChanged: (String? newValue) {
          if (newValue != null) {
            systemStateProvider.selectRecipe(newValue);
          }
        },
        items: recipeProvider.recipes.map<DropdownMenuItem<String>>((Recipe recipe) {
          return DropdownMenuItem<String>(
            value: recipe.id,
            child: Text(recipe.name, overflow: TextOverflow.ellipsis),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecipeControls(BuildContext context, RecipeProvider recipeProvider, SystemStateProvider systemStateProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(
          onPressed: systemStateProvider.selectedRecipe != null && systemStateProvider.activeRecipe == null
              ? () => _startRecipe(context, systemStateProvider)
              : null,
          child: Icon(Icons.play_arrow, color: Colors.white, size: 18),
          color: Colors.green,
        ),
        SizedBox(width: 8),
        _buildControlButton(
          onPressed: systemStateProvider.activeRecipe != null
              ? () => systemStateProvider.stopSystem()
              : null,
          child: Icon(Icons.stop, color: Colors.white, size: 18),
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildControlButton({required VoidCallback? onPressed, required Widget child, required Color color}) {
    return SizedBox(
      width: 30,
      height: 30,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _startRecipe(BuildContext context, SystemStateProvider systemStateProvider) async {
    if (systemStateProvider.selectedRecipe != null) {
      try {
        await systemStateProvider.executeRecipe(systemStateProvider.selectedRecipe!);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error executing recipe: $e')),
        );
      }
    }
  }
}