// lib/screens/safety_procedures_screen.dart
import 'package:flutter/material.dart';

class SafetyProceduresScreen extends StatelessWidget {
  final List<SafetyProcedure> procedures = [
    SafetyProcedure(
      title: 'General Safety Guidelines',
      steps: [
        'Always wear appropriate Personal Protective Equipment (PPE)',
        'Familiarize yourself with emergency shutdown procedures',
        'Maintain a clean and organized work area',
        'Report any equipment malfunctions immediately',
      ],
    ),
    SafetyProcedure(
      title: 'Chemical Handling',
      steps: [
        'Review Safety Data Sheets (SDS) before handling any chemicals',
        'Use proper containment and ventilation when working with precursors',
        'Dispose of chemical waste according to regulations',
        'In case of spills, follow the specified cleanup procedure',
      ],
    ),
    SafetyProcedure(
      title: 'Lockout/Tagout Procedure',
      steps: [
        'Identify all energy sources to be controlled',
        'Notify all affected employees',
        'Shut down the equipment',
        'Isolate the equipment from energy sources',
        'Apply lockout/tagout devices',
        'Verify isolation of energy',
      ],
    ),
    SafetyProcedure(
      title: 'Emergency Shutdown',
      steps: [
        'Press the emergency stop button',
        'Close all gas supply valves',
        'Turn off the main power supply',
        'Evacuate the area if necessary',
        'Contact your supervisor and safety officer',
      ],
    ),
  ];

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
        title: Text('Safety Procedures'),
      ),
      body: ListView.builder(
        itemCount: procedures.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              procedures[index].title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            children: procedures[index].steps.map((step) {
              return ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text(step),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEmergencyContactsDialog(context);
        },
        child: Icon(Icons.emergency),
        backgroundColor: Colors.red,
        tooltip: 'Emergency Contacts',
      ),
    );
  }

  void _showEmergencyContactsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emergency Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Safety Officer: John Doe'),
              Text('Phone: +1 (555) 123-4567'),
              SizedBox(height: 8),
              Text('Facility Manager: Jane Smith'),
              Text('Phone: +1 (555) 987-6543'),
              SizedBox(height: 8),
              Text('Emergency Services: 911'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SafetyProcedure {
  final String title;
  final List<String> steps;

  SafetyProcedure({required this.title, required this.steps});
}