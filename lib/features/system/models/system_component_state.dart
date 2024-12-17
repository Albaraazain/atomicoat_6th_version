class SystemComponentState {
  final bool isInitialized;
  final bool isConnected;
  final bool hasError;
  final String? errorMessage;
  final Map<String, dynamic> currentValues;
  final Map<String, dynamic> setValues;
  final String name;

  const SystemComponentState({
    required this.name,
    this.isInitialized = false,
    this.isConnected = false,
    this.hasError = false,
    this.errorMessage,
    this.currentValues = const {},
    this.setValues = const {},
  });

  SystemComponentState copyWith({
    String? name,
    bool? isInitialized,
    bool? isConnected,
    bool? hasError,
    String? errorMessage,
    Map<String, dynamic>? currentValues,
    Map<String, dynamic>? setValues,
  }) {
    return SystemComponentState(
      name: name ?? this.name,
      isInitialized: isInitialized ?? this.isInitialized,
      isConnected: isConnected ?? this.isConnected,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentValues: currentValues ?? this.currentValues,
      setValues: setValues ?? this.setValues,
    );
  }
}
