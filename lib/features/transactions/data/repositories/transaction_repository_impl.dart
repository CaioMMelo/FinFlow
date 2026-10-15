import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final models = await localDataSource.getLastTransactions();
      return Right(models);
    } catch (e) {
      return DatabaseFailure('Erro ao carregar transações locais: $e') as Either<Failure, List<TransactionEntity>>;
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.cacheTransaction(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao persistir transação: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await localDataSource.deleteTransaction(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao remover transação: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalBalanceInCents() async {
    try {
      final list = await localDataSource.getLastTransactions();
      int total = 0;
      for (final t in list) {
        if (t.type == TransactionType.income) {
          total += t.amountInCents;
        } else if (t.type == TransactionType.expense) {
          total -= t.amountInCents;
        }
      }
      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao calcular saldo: $e'));
    }
  }
}

