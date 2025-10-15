import '../../core/utils/result.dart';

/// Base class for all use cases
/// Follows the Single Responsibility Principle
abstract class UseCase<Type, Params> {
  Future<Result<Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  Future<Result<Type>> call();
}
