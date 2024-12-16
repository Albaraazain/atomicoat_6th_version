// test/blocs/system_state/system_state_bloc_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment_planner/features/system/repositories/system_state_repository.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_bloc.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_event.dart';
import 'package:experiment_planner/blocs/system_state/bloc/system_state_state.dart';
import 'package:experiment_planner/blocs/system_state/models/system_state_data.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../helpers/firebase_test_setup.dart';

// Mock Firebase setup
class MockFirebaseApp extends Mock implements FirebaseApp {}

// Setup mock Firebase initialization
Future<void> setupFirebaseAuthMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup mock Firebase app
  final mockApp = MockFirebaseApp();
  when(() => Firebase.app()).thenReturn(mockApp);
  when(() => Firebase.initializeApp()).thenAnswer((_) async => mockApp);
}

class TestSystemStateRepository extends SystemStateRepository {
  final FakeFirebaseFirestore fakeFirestore;
  SystemStateData? _mockState;

  TestSystemStateRepository({required this.fakeFirestore}) : super();

  void setMockState(SystemStateData state) {
    _mockState = state;
  }

  @override
  Future<SystemStateData?> getSystemState() async {
    return _mockState;
  }

  @override
  Stream<SystemStateData?> systemStateStream() {
    return Stream.value(_mockState);
  }

  @override
  Future<void> saveSystemState(Map<String, dynamic> stateData) async {
    String id = DateTime.now().millisecondsSinceEpoch.toString();
    await fakeFirestore.collection('system_states').doc(id).set({
      ...stateData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> saveComponentState(String userId, SystemComponent component) async {
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('system_components')
        .doc(component.name)
        .set(component.toJson());
  }

  @override
  Future<SystemComponent?> getComponentByName(String userId, String name) async {
    final doc = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('system_components')
        .doc(name)
        .get();

    if (doc.exists) {
      return SystemComponent.fromJson(doc.data()!);
    }
    return null;
  }

  @override
  Future<List<SystemComponent>> getAllComponents(String userId) async {
    final snapshot = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('system_components')
        .get();

    return snapshot.docs
        .map((doc) => SystemComponent.fromJson(doc.data()))
        .toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SystemStateBloc bloc;
  late TestSystemStateRepository repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUpAll(() async {
    // Initialize mock Firebase
    await setupFirebaseAuthMocks();
  });

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = TestSystemStateRepository(fakeFirestore: fakeFirestore);
    bloc = SystemStateBloc(repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('SystemStateBloc Tests', () {
    test('initial state is correct', () {
      expect(bloc.state.status, equals(SystemOperationalStatus.uninitialized));
      expect(bloc.state.isSystemRunning, isFalse);
      expect(bloc.state.systemIssues, isEmpty);
      expect(bloc.state.currentSystemState, isEmpty);
      expect(bloc.state.lastStateUpdate, isNull);
      expect(bloc.state.isReadinessCheckPassed, isFalse);
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.error, isNull);
    });

    blocTest<SystemStateBloc, SystemStateState>(
      'initializes with existing state',
      build: () {
        final mockState = SystemStateData(
          id: '1',
          data: {
            'components': {
              'component1': {
                'isActivated': true,
                'currentValues': {'temp': 25.0},
                'setValues': {'temp': 25.0},
              }
            }
          },
          timestamp: DateTime.now(),
        );

        repository.setMockState(mockState);
        return bloc;
      },
      act: (bloc) => bloc.add(InitializeSystem()),
      expect: () => [
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.initializing &&
            state.isLoading == true),
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.ready &&
            state.isLoading == false),
      ],
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'handles start system when ready',
      build: () => bloc,
      seed: () => SystemStateState(
        status: SystemOperationalStatus.ready,
        isSystemRunning: false,
        systemIssues: [],
      ),
      act: (bloc) => bloc.add(StartSystem()),
      expect: () => [
        predicate<SystemStateState>((state) =>
            state.isLoading == true),
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.running &&
            state.isSystemRunning == true &&
            state.isLoading == false),
      ],
    );

    blocTest<SystemStateBloc, SystemStateState>(
      'handles emergency stop from any state',
      build: () => bloc,
      act: (bloc) => bloc.add(EmergencyStop()),
      expect: () => [
        predicate<SystemStateState>((state) =>
            state.isLoading == true),
        predicate<SystemStateState>((state) =>
            state.status == SystemOperationalStatus.emergencyStopped &&
            state.isSystemRunning == false &&
            state.isLoading == false),
      ],
    );
  });
}