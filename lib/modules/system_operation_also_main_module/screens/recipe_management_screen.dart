// lib/modules/system_operation_also_main_module/screens/recipe_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_bloc.dart';
import '../../../blocs/recipe/bloc/recipe_event.dart';
import '../../../blocs/recipe/bloc/recipe_state.dart';
import '../models/recipe.dart';
import 'recipe_detail_screen.dart';

class RecipeManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecipeBloc, RecipeState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: Text(
              'Recipe Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, size: 28),
                onPressed: () => _navigateToRecipeDetail(context),
              ),
            ],
          ),
          body: state.isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildRecipeList(context, state),
        );
      },
    );
  }

  Widget _buildRecipeList(BuildContext context, RecipeState state) {
    if (state.recipes.isEmpty) {
      return Center(
        child: Text('No recipes available'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: state.recipes.length,
        itemBuilder: (context, index) {
          final recipe = state.recipes[index];
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                recipe.name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Steps: ${recipe.steps.length}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToRecipeDetail(context, recipeId: recipe.id),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteRecipe(context, recipe),
                  ),
                ],
              ),
              onTap: () => _showRecipeDetails(context, recipe),
            ),
          );
        },
      ),
    );
  }

  void _navigateToRecipeDetail(BuildContext context, {String? recipeId}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipeId: recipeId),
      ),
    );

    if (result == true) {
      // Recipe was saved, refresh the list
      context.read<RecipeBloc>().add(LoadRecipes());
    }
  }

  void _confirmDeleteRecipe(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Delete',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete the recipe "${recipe.name}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                context.read<RecipeBloc>().add(DeleteRecipe(recipe.id));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRecipeDetails(BuildContext context, Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            recipe.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Substrate: ${recipe.substrate}'),
                SizedBox(height: 10),
                Text(
                  'Steps:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...recipe.steps.map((step) => Padding(
                  padding: EdgeInsets.only(left: 10, top: 5),
                  child: Text('- ${_getStepDescription(step)}', style: TextStyle(fontSize: 14)),
                )).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  String _getStepDescription(RecipeStep step) {
    switch (step.type) {
      case StepType.valve:
        return 'Open ${step.parameters['valveType']} for ${step.parameters['duration']}s';
      case StepType.purge:
        return 'Purge for ${step.parameters['duration']}s';
      case StepType.loop:
        return 'Loop ${step.parameters['iterations']} times';
      case StepType.setParameter:
        return 'Set ${step.parameters['parameter']} of ${step.parameters['component']} to ${step.parameters['value']}';
      default:
        return 'Unknown step';
    }
  }
}