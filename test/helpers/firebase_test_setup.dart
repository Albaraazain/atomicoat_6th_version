// test/helpers/firebase_test_setup.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> setupFirebaseTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up mock platform channels
  const channel = MethodChannel('plugins.flutter.io/firebase_core');
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Firebase#initializeCore':
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': {},
          }
        ];
      case 'Firebase#initializeApp':
        return {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'test-api-key',
            'appId': 'test-app-id',
            'messagingSenderId': 'test-sender-id',
            'projectId': 'test-project-id',
          },
          'pluginConstants': {},
        };
      default:
        return null;
    }
  });
}