// lib/core/utils/typedefs.dart
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultStream<T> = Stream<Either<Failure, T>>;
typedef DataMap = Map<String, dynamic>;