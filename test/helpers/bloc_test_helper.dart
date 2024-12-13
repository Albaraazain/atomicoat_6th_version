// test/helpers/bloc_test_helper.dart

import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../lib/blocs/base/base_repository.dart';

/// Mock Firestore for testing
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Mock CollectionReference for testing
class MockCollectionReference extends Mock implements CollectionReference {}

/// Mock DocumentReference for testing
class MockDocumentReference extends Mock implements DocumentReference {}

/// Base class for repository mocks
class MockBlocRepository<T> extends Mock implements BlocRepository<T> {}

/// Helper to create a mock repository
MockBlocRepository<T> createMockRepository<T>() {
  final repository = MockBlocRepository<T>();
  when(() => repository.collectionName).thenReturn('test_collection');
  return repository;
}

/// Extension to help with bloc testing
extension BlocTestHelper on dynamic {
  void expectStateChanges<B extends BlocBase<S>, S>({
    required B Function() build,
    required List<S> expectedStates,
    Function(B)? act,
  }) {
    blocTest<B, S>(
      'emits $expectedStates',
      build: build,
      act: act,
      expect: () => expectedStates,
    );
  }
}