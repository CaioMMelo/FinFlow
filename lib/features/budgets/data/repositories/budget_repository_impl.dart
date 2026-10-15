import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_local_datasource.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets() async {
    try {
      final models = await localDataSource.getBudgets();
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao carregar orçamentos: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> createBudget(BudgetEntity budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      await localDataSource.saveBudget(model);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao salvar orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudgetSpending(String id, int amountInCents) async {
    try {
      await localDataSource.updateSpending(id, amountInCents);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao atualizar gastos do orçamento: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await localDataSource.deleteBudget(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao remover orçamento: $e'));
    }
  }
}

