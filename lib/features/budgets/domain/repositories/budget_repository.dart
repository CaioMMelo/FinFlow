import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/budget_entity.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<BudgetEntity>>> getBudgets();
  Future<Either<Failure, void>> createBudget(BudgetEntity budget);
  Future<Either<Failure, void>> updateBudgetSpending(String id, int amountInCents);
  Future<Either<Failure, void>> deleteBudget(String id);
}

