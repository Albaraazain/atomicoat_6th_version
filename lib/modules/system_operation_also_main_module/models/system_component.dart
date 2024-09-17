import 'data_point.dart';

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

  factory SystemComponent.fromJson(Map<String, dynamic> json) {
    return SystemComponent(
      name: json['name'] as String,
      description: json['description'] as String,
      status: ComponentStatus.values.firstWhere((e) => e.toString() == 'ComponentStatus.${json['status']}'),
      currentValues: Map<String, double>.from(json['currentValues']),
      setValues: Map<String, double>.from(json['setValues']),
      errorMessages: List<String>.from(json['errorMessages']),
      isActivated: json['isActivated'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'status': status.toString().split('.').last,
    'currentValues': currentValues,
    'setValues': setValues,
    'errorMessages': errorMessages,
    'isActivated': isActivated,
  };
}

enum ComponentStatus {
  normal,
  warning,
  error
}
