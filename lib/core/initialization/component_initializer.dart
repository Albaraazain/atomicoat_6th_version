import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../features/components/models/system_component.dart';

class ComponentInitializer {
  static final List<Map<String, dynamic>> defaultComponents = [
    {
      'id': 'reactor_chamber',
      'name': 'Reactor Chamber',
      'description': 'Main ALD reaction chamber',
      'type': 'chamber',
      'currentValues': {
        'temperature': 25.0,
        'pressure': 1.0,
        'humidity': 45.0
      },
      'setValues': {
        'temperature': 200.0,
        'pressure': 5.0,
        'humidity': 30.0
      },
      'minValues': {
        'temperature': 15.0,
        'pressure': 0.1,
        'humidity': 20.0
      },
      'maxValues': {
        'temperature': 300.0,
        'pressure': 10.0,
        'humidity': 60.0
      },
      'status': 'normal',
      'isActivated': true,
      'errorMessages': [],
      'position': {'x': 100.0, 'y': 100.0}
    },
    {
      'id': 'precursor_a',
      'name': 'Precursor A',
      'description': 'First precursor inlet system',
      'type': 'precursor',
      'currentValues': {
        'flow_rate': 0.0,
        'temperature': 25.0,
        'pressure': 1.0
      },
      'setValues': {
        'flow_rate': 20.0,
        'temperature': 150.0,
        'pressure': 2.0
      },
      'minValues': {
        'flow_rate': 0.0,
        'temperature': 10.0,
        'pressure': 0.1
      },
      'maxValues': {
        'flow_rate': 50.0,
        'temperature': 200.0,
        'pressure': 5.0
      },
      'status': 'normal',
      'isActivated': true,
      'errorMessages': [],
      'position': {'x': 300.0, 'y': 100.0}
    },
    {
      'id': 'precursor_b',
      'name': 'Precursor B',
      'description': 'Second precursor inlet system',
      'type': 'precursor',
      'currentValues': {
        'flow_rate': 0.0,
        'temperature': 25.0,
        'pressure': 1.0
      },
      'setValues': {
        'flow_rate': 20.0,
        'temperature': 150.0,
        'pressure': 2.0
      },
      'minValues': {
        'flow_rate': 0.0,
        'temperature': 10.0,
        'pressure': 0.1
      },
      'maxValues': {
        'flow_rate': 50.0,
        'temperature': 200.0,
        'pressure': 5.0
      },
      'status': 'normal',
      'isActivated': true,
      'errorMessages': [],
      'position': {'x': 500.0, 'y': 100.0}
    },
    {
      'id': 'vacuum_system',
      'name': 'Vacuum System',
      'description': 'Vacuum and exhaust system',
      'type': 'vacuum',
      'currentValues': {
        'pressure': 1.0,
        'pump_speed': 0.0
      },
      'setValues': {
        'pressure': 0.01,
        'pump_speed': 60.0
      },
      'minValues': {
        'pressure': 0.001,
        'pump_speed': 0.0
      },
      'maxValues': {
        'pressure': 1.0,
        'pump_speed': 100.0
      },
      'status': 'normal',
      'isActivated': true,
      'errorMessages': [],
      'position': {'x': 100.0, 'y': 300.0}
    },
    {
      'id': 'heater_system',
      'name': 'Heater System',
      'description': 'Substrate heating system',
      'type': 'heater',
      'currentValues': {
        'temperature': 25.0,
        'power': 0.0
      },
      'setValues': {
        'temperature': 200.0,
        'power': 1000.0
      },
      'minValues': {
        'temperature': 15.0,
        'power': 0.0
      },
      'maxValues': {
        'temperature': 300.0,
        'power': 2000.0
      },
      'status': 'normal',
      'isActivated': true,
      'errorMessages': [],
      'position': {'x': 300.0, 'y': 300.0}
    }
  ];

  static Future<void> initializeSystemComponents() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    final componentsRef = firestore.collection('system_components');

    // Check if components already exist
    final snapshot = await componentsRef.get();
    if (snapshot.docs.isEmpty) {
      // Initialize default components
      for (final component in defaultComponents) {
        final docRef = componentsRef.doc(component['id']);
        batch.set(docRef, {
          ...component,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
      debugPrint('Initialized ${defaultComponents.length} default components');
    } else {
      debugPrint('Components already initialized, found ${snapshot.docs.length} existing components');
    }
  }
}
