// system_component.dart

import 'data_point.dart';

enum ComponentStatus { normal, warning, error }

class SystemComponent {
  final String name;
  final String description;
  ComponentStatus status;
  Map<String, double> currentValues;
  Map<String, double> setValues;
  List<String> errorMessages;
  Map<String, List<DataPoint>> parameterHistory;
  bool isActivated;

  SystemComponent({
    required this.name,
    required this.description,
    this.status = ComponentStatus.normal,
    required this.currentValues,
    required this.setValues,
    this.errorMessages = const [],
    this.isActivated = false,
  }) : parameterHistory = {
    for (var key in currentValues.keys) key: [],
  };
}
