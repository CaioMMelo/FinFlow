import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Contrato padrão para todos os Use Cases da aplicação.
/// Retorna `Either<Failure, Type>`, garantindo fluxo explícito de sucesso/falha sem throw de exceptions não tratadas.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Usado quando o UseCase não requer parâmetros de entrada.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}

