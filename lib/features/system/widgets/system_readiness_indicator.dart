

import 'package:experiment_planner/features/recipes/bloc/recipe_bloc.dart';
import 'package:experiment_planner/features/recipes/bloc/recipe_state.dart';
import 'package:experiment_planner/features/system/bloc/system_state_bloc.dart';
import 'package:experiment_planner/features/system/bloc/system_state_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class SystemReadinessIndicator extends StatefulWidget {
  @override
  _SystemReadinessIndicatorState createState() => _SystemReadinessIndicatorState();
}

class _SystemReadinessIndicatorState extends State<SystemReadinessIndicator> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemStateBloc, SystemStateState>(
      builder: (context, systemState) {
        return BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, recipeState) {
            // First check if system is running
            if (systemState.isSystemRunning) {
              return _buildRunningIndicator(recipeState.activeRecipe?.name);
            }

            // If not running, show regular readiness status
            final issues = systemState.systemIssues;
            final isReady = issues.isEmpty;

            return AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < -20) {
                    setState(() => _isExpanded = true);
                  } else if (details.primaryDelta! > 20) {
                    setState(() => _isExpanded = false);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusBar(isReady),
                    if (_isExpanded && !isReady)
                      _buildIssuesList(issues),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRunningIndicator(String? recipeName) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: Colors.green.withOpacity(0.9),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.play_circle,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'System Running${recipeName != null ? ': $recipeName' : ''}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(bool isReady) {
    return Container(
      color: isReady ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
      child: SafeArea(
        top: false,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  isReady ? Icons.check_circle : Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  isReady ? 'System Ready' : 'System Not Ready',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_more : Icons.expand_less,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssuesList(List<String> issues) {
    return Container(
      color: Colors.black87,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issues:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                ...issues.map((issue) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issue,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}