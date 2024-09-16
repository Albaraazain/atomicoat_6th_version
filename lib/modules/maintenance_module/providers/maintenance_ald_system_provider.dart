// lib/providers/diagram_ald_system_provider.dart
import 'package:flutter/foundation.dart';

class MaintenanceSystemStateProvider with ChangeNotifier {
  bool _n2GenActive = false;
  bool _frontlineHeaterActive = false;
  bool _backlineHeaterActive = false;
  bool _pumpActive = false;
  bool _v1Open = false;
  bool _v2Open = false;
  bool _h1Active = false;
  bool _h2Active = false;
  double _mfcActualFlow = 0.0;

  bool get n2GenActive => _n2GenActive;
  bool get frontlineHeaterActive => _frontlineHeaterActive;
  bool get backlineHeaterActive => _backlineHeaterActive;
  bool get pumpActive => _pumpActive;
  bool get v1Open => _v1Open;
  bool get v2Open => _v2Open;
  bool get h1Active => _h1Active;
  bool get h2Active => _h2Active;
  double get mfcActualFlow => _mfcActualFlow;

  void toggleN2Gen() {
    _n2GenActive = !_n2GenActive;
    notifyListeners();
  }

  void toggleFrontlineHeater() {
    _frontlineHeaterActive = !_frontlineHeaterActive;
    notifyListeners();
  }

  void toggleBacklineHeater() {
    _backlineHeaterActive = !_backlineHeaterActive;
    notifyListeners();
  }

  void togglePump() {
    _pumpActive = !_pumpActive;
    notifyListeners();
  }

  void toggleValve(String valve) {
    if (valve == 'v1') {
      _v1Open = !_v1Open;
    } else if (valve == 'v2') {
      _v2Open = !_v2Open;
    }
    notifyListeners();
  }

  void toggleHeater(String heater) {
    if (heater == 'h1') {
      _h1Active = !_h1Active;
    } else if (heater == 'h2') {
      _h2Active = !_h2Active;
    }
    notifyListeners();
  }

  void setMFCFlow(double flow) {
    _mfcActualFlow = flow;
    notifyListeners();
  }

  void toggleMFC() {
    if (_mfcActualFlow > 0) {
      _mfcActualFlow = 0;
    } else {
      _mfcActualFlow = 10; // Arbitrary non-zero value
    }
    notifyListeners();
  }
}