import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class CreateBudget implements UseCase<void, BudgetEntity> {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(BudgetEntity budget) async {
    if (budget.name.trim().isEmpty) {
      return const Left(ValidationFailure('O nome da meta/orçamento é obrigatório.'));
    }
    if (budget.targetAmountInCents <= 0) {
      return const Left(ValidationFailure('O valor do orçamento deve ser superior a zero.'));
    }

    return await repository.createBudget(budget);
  }
}

