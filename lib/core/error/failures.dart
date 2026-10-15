import 'package:equatable/equatable.dart';

/// Classe base abstrata para tratamento padronizado de falhas na Clean Architecture.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Falha ao acessar ou persistir dados na base local criptografada.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Falha na persistência local de dados.']);
}

/// Falha de autenticação biométrica ou violação de integridade.
class SecurityFailure extends Failure {
  const SecurityFailure([super.message = 'Falha na validação de segurança ou biometria.']);
}

/// Falha de validação de regras de negócio financeiras (ex: saldo insuficiente, valor negativo).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Falha de comunicação ou sincronização com a nuvem.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sem conexão com a internet para sincronização.']);
}

