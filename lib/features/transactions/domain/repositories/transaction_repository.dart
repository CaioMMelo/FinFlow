import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction_entity.dart';

/// Contrato abstrato do repositório de transações (Princípio da Inversão de Dependência).
/// O Domínio não sabe se os dados vêm de SQLite, Drift, Firebase ou uma API REST.
abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, int>> getTotalBalanceInCents();
}

