// lib/widgets/troubleshooting_tree_widget.dart
import 'package:flutter/material.dart';
import '../models/troubleshooting_step.dart';

class TroubleshootingTreeWidget extends StatefulWidget {
  final List<TroubleshootingStep> steps;
  final Function(String) onOptionSelected;

  const TroubleshootingTreeWidget({
    Key? key,
    required this.steps,
    required this.onOptionSelected,
  }) : super(key: key);

  @override
  _TroubleshootingTreeWidgetState createState() => _TroubleshootingTreeWidgetState();
}

class _TroubleshootingTreeWidgetState extends State<TroubleshootingTreeWidget> {
  int _currentStepIndex = 0;
  List<String> _selectedOptions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Troubleshooting Step ${_currentStepIndex + 1}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Text(
          widget.steps[_currentStepIndex].question,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 16),
        ..._buildOptions(),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStepIndex > 0)
              ElevatedButton(
                onPressed: _goToPreviousStep,
                child: Text('Previous'),
              ),
            ElevatedButton(
              onPressed: _currentStepIndex < widget.steps.length - 1 ? _goToNextStep : _showFinalRecommendation,
              child: Text(_currentStepIndex < widget.steps.length - 1 ? 'Next' : 'Finish'),
            ),
          ],
        ),
        if (_selectedOptions.isNotEmpty) ...[
          SizedBox(height: 24),
          Text(
            'Selected path:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8),
          ..._buildSelectedPath(),
        ],
      ],
    );
  }

  List<Widget> _buildOptions() {
    return widget.steps[_currentStepIndex].options.map((option) {
      return RadioListTile<String>(
        title: Text(option),
        value: option,
        groupValue: _selectedOptions.length > _currentStepIndex ? _selectedOptions[_currentStepIndex] : null,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              if (_selectedOptions.length > _currentStepIndex) {
                _selectedOptions[_currentStepIndex] = value;
              } else {
                _selectedOptions.add(value);
              }
            });
          }
        },
      );
    }).toList();
  }

  List<Widget> _buildSelectedPath() {
    return _selectedOptions.asMap().entries.map((entry) {
      int index = entry.key;
      String option = entry.value;
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Text('${index + 1}. ${widget.steps[index].question} - $option'),
      );
    }).toList();
  }

  void _goToPreviousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  void _goToNextStep() {
    if (_currentStepIndex < widget.steps.length - 1 &&
        _selectedOptions.length > _currentStepIndex) {
      setState(() {
        _currentStepIndex++;
      });
    }
  }

  void _showFinalRecommendation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Troubleshooting Recommendation'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Based on your selections, here is the recommended action:'),
                SizedBox(height: 16),
                Text(
                  _selectedOptions.last,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Text('Troubleshooting path:'),
                SizedBox(height: 8),
                ..._buildSelectedPath(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetTroubleshooting();
              },
              child: Text('Start Over'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _resetTroubleshooting() {
    setState(() {
      _currentStepIndex = 0;
      _selectedOptions.clear();
    });
  }
}