import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';

class GetBudgets implements UseCase<List<BudgetEntity>, NoParams> {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(NoParams params) async {
    return await repository.getBudgets();
  }
}

