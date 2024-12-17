// lib/core/app/app_bootstrap.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase if not already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Initialize Crashlytics
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      // Initialize other services here
      await _createFirestoreIndexes();
    } catch (e, stack) {
      print('Initialization error: $e');
      print(stack);
      rethrow;
    }
  }

  static Future<void> _createFirestoreIndexes() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final indexDoc = await firestore.collection('alarms').doc('__indexes__').get();

      if (indexDoc.exists) return;

      await firestore.collection('alarms').doc('__indexes__').set({
        'composite_indexes': [{
          'fields': [
            {'fieldPath': 'acknowledged', 'order': 'ASCENDING'},
            {'fieldPath': 'timestamp', 'order': 'DESCENDING'},
            {'fieldPath': '__name__', 'order': 'DESCENDING'}
          ],
          'queryScope': 'COLLECTION'
        }]
      });
    } catch (e) {
      print('Error creating Firestore indexes: $e');
    }
  }
}