import 'package:cloud_firestore/cloud_firestore.dart';
import 'data_point.dart';
import '../../maintenance_module/models/maintenance_task.dart';

enum ComponentStatus { normal, warning, error, ok }

class SystemComponent {
  final String name;
  final String description;
  ComponentStatus status;
  final Map<String, double> currentValues;
  final Map<String, double> setValues;
  final List<String> errorMessages;
  final Map<String, CircularBuffer<DataPoint>> parameterHistory;
  bool isActivated;
  final List<MaintenanceTask> maintenanceTasks;

  DateTime? lastCheckDate;
  final Map<String, double> minValues;
  final Map<String, double> maxValues;

  static const int MAX_HISTORY_SIZE = 100;


  SystemComponent({
    required this.name,
    required this.description,
    this.status = ComponentStatus.normal,
    required Map<String, double> currentValues,
    required Map<String, double> setValues,
    List<String>? errorMessages,
    this.isActivated = false,
    this.lastCheckDate,
    Map<String, double>? minValues,
    Map<String, double>? maxValues,
    this.maintenanceTasks = const [], // Default to empty list
  })  : currentValues = Map.from(currentValues),
        setValues = Map.from(setValues),
        errorMessages = errorMessages ?? [],
        minValues = minValues ?? {},
        maxValues = maxValues ?? {},
        parameterHistory = Map.fromEntries(
          currentValues.keys.map(
                (key) => MapEntry(key, CircularBuffer<DataPoint>(MAX_HISTORY_SIZE)),
          ),
        );

  void updateCurrentValues(Map<String, double> values) {
    currentValues.addAll(values);
    values.forEach((parameter, value) {
      parameterHistory[parameter]?.add(
        DataPoint.reducedPrecision(
          timestamp: DateTime.now(),
          value: value,
        ),
      );
    });
  }

  void updateSetValues(Map<String, double> values) {
    setValues.addAll(values);
  }

  void addErrorMessage(String message) {
    errorMessages.add(message);
  }

  void clearErrorMessages() {
    errorMessages.clear();
  }

  void updateLastCheckDate(DateTime date) {
    lastCheckDate = date;
  }

  void updateMinValues(Map<String, double> newMinValues) {
    minValues.addAll(newMinValues);
  }

  void updateMaxValues(Map<String, double> newMaxValues) {
    maxValues.addAll(newMaxValues);
  }

  factory SystemComponent.fromJson(Map<String, dynamic> json) {
    final component = SystemComponent(
      name: json['name'] as String,
      description: json['description'] as String,
      status: ComponentStatus.values.firstWhere(
            (e) => e.toString() == 'ComponentStatus.${json['status']}',
      ),
      currentValues: Map<String, double>.from(json['currentValues']),
      setValues: Map<String, double>.from(json['setValues']),
      errorMessages: List<String>.from(json['errorMessages']),
      isActivated: json['isActivated'] as bool,
      lastCheckDate: json['lastCheckDate'] != null
          ? (json['lastCheckDate'] as Timestamp).toDate()
          : null,
      minValues: json['minValues'] != null
          ? Map<String, double>.from(json['minValues'])
          : null,
      maxValues: json['maxValues'] != null
          ? Map<String, double>.from(json['maxValues'])
          : null,
      maintenanceTasks: (json['maintenanceTasks'] as List?)
          ?.map((task) => MaintenanceTask.fromJson(task))
          .toList() ?? [],
    );

    if (json['parameterHistory'] != null) {
      (json['parameterHistory'] as Map<String, dynamic>).forEach((key, value) {
        final buffer = component.parameterHistory[key];
        if (buffer != null) {
          final dataPoints = (value as List)
              .map((dp) => DataPoint.fromJson(dp as Map<String, dynamic>))
              .take(MAX_HISTORY_SIZE)
              .toList();
          buffer.addAll(dataPoints);
        }
      });
    }

    return component;
  }


  void _loadParameterHistory(Map<String, dynamic>? historyJson) {
    if (historyJson == null) return;
    historyJson.forEach((key, value) {
      final buffer = parameterHistory[key];
      if (buffer != null) {
        final dataPoints = (value as List)
            .map((dp) => DataPoint.fromJson(dp))
            .take(MAX_HISTORY_SIZE)
            .toList();
        buffer.addAll(dataPoints);
      }
    });
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'status': status.toString().split('.').last,
    'currentValues': currentValues,
    'setValues': setValues,
    'errorMessages': errorMessages,
    'isActivated': isActivated,
    'lastCheckDate':
    lastCheckDate != null ? Timestamp.fromDate(lastCheckDate!) : null,
    'minValues': minValues,
    'maxValues': maxValues,
    'parameterHistory': parameterHistory.map(
          (key, value) => MapEntry(
        key,
        value.toList().map((dp) => dp.toJson()).toList(),
      ),
    ),
    'maintenanceTasks': maintenanceTasks.map((task) => task.toJson()).toList(),
  };

  String get type => name;
  DateTime get lastMaintenanceDate => lastCheckDate!;
  String get id => name;

  SystemComponent copyWith({
    String? name,
    String? description,
    ComponentStatus? status,
    Map<String, double>? currentValues,
    Map<String, double>? setValues,
    List<String>? errorMessages,
    bool? isActivated,
    DateTime? lastCheckDate,
    Map<String, double>? minValues,
    Map<String, double>? maxValues,
    List<MaintenanceTask>? maintenanceTasks,
  }) {
    return SystemComponent(
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      currentValues: currentValues ?? this.currentValues,
      setValues: setValues ?? this.setValues,
      errorMessages: errorMessages ?? this.errorMessages,
      isActivated: isActivated ?? this.isActivated,
      lastCheckDate: lastCheckDate ?? this.lastCheckDate,
      minValues: minValues ?? this.minValues,
      maxValues: maxValues ?? this.maxValues,
      maintenanceTasks: maintenanceTasks ?? this.maintenanceTasks,
    );
  }
}

class CircularBuffer<T> {
  final int capacity;
  final List<T?> _buffer;
  int _start = 0;
  int _length = 0;

  CircularBuffer(this.capacity) : _buffer = List<T?>.filled(capacity, null);

  void add(T item) {
    if (_length < capacity) {
      _buffer[_length++] = item;
    } else {
      _buffer[_start] = item;
      _start = (_start + 1) % capacity;
    }
  }

  void addAll(Iterable<T> items) {
    for (var item in items) {
      add(item);
    }
  }

  List<T> toList() {
    if (_length < capacity) {
      return _buffer.sublist(0, _length).cast<T>();
    } else {
      return [
        ..._buffer.sublist(_start).cast<T>(),
        ..._buffer.sublist(0, _start).cast<T>(),
      ];
    }
  }

  // Add these new methods and properties
  bool get isEmpty => _length == 0;
  bool get isNotEmpty => _length > 0;
  int get length => _length;

  T? operator [](int index) {
    if (index < 0 || index >= _length) return null;
    return _buffer[(_start + index) % capacity];
  }

  void removeAt(int index) {
    if (index < 0 || index >= _length) return;
    final actualIndex = (_start + index) % capacity;
    for (int i = actualIndex; i < _length - 1; i++) {
      _buffer[i % capacity] = _buffer[(i + 1) % capacity];
    }
    _length--;
  }

  T? get first => isEmpty ? null : _buffer[_start];
  T? get last => isEmpty ? null : _buffer[(_start + _length - 1) % capacity];

  Map<int, T> asMap() {
    return Map.fromEntries(
      Iterable.generate(_length, (index) => MapEntry(index, this[index]!)),
    );
  }

  Iterable<R> map<R>(R Function(T) toElement) {
    return Iterable.generate(_length, (index) => toElement(this[index]!));
  }
}