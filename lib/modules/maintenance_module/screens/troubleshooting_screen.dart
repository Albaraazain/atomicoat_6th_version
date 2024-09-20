import 'package:flutter/material.dart';
import '../models/troubleshooting_step.dart';
import '../widgets/troubleshooting_tree_widget.dart';

class TroubleshootingScreen extends StatefulWidget {
  @override
  _TroubleshootingScreenState createState() => _TroubleshootingScreenState();
}

class _TroubleshootingScreenState extends State<TroubleshootingScreen> {
  late List<TroubleshootingStep> _troubleshootingSteps;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _troubleshootingSteps = _initializeTroubleshootingSteps();
  }

  List<TroubleshootingStep> _initializeTroubleshootingSteps() {
    // This is a simplified example. In a real app, this data might come from a database or API.
    return [
      TroubleshootingStep(
        question: 'What is the main issue you are experiencing?',
        options: ['Poor film uniformity', 'Unexpected growth rates', 'Pressure control problems', 'Temperature fluctuations'],
      ),
      TroubleshootingStep(
        question: 'For poor film uniformity, check the following:',
        options: ['Precursor flow rates', 'Substrate temperature uniformity', 'Chamber pressure stability'],
      ),
      // Add more steps as needed
    ];
  }

  void _handleOptionSelected(String selectedOption) {
    setState(() {
      if (_currentStepIndex < _troubleshootingSteps.length - 1) {
        _currentStepIndex++;
      } else {
        // Reached the end of the troubleshooting tree
        _showFinalRecommendation(selectedOption);
      }
    });
  }

  void _showFinalRecommendation(String finalOption) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Recommendation'),
        content: Text('Based on your selections, we recommend the following action: $finalOption'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetTroubleshooting();
            },
            child: Text('Start Over'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetTroubleshooting() {
    setState(() {
      _currentStepIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Troubleshooting Guide'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetTroubleshooting,
            tooltip: 'Start Over',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${_currentStepIndex + 1} of ${_troubleshootingSteps.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TroubleshootingTreeWidget(
                steps: _troubleshootingSteps,
                onOptionSelected: _handleOptionSelected,
              )
            ],
          ),
        ),
      ),
    );
  }
}
