import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/insight_entity.dart';
import '../repositories/insight_repository.dart';

class GetFinancialInsights implements UseCase<FinancialInsightEntity, NoParams> {
  final InsightRepository repository;

  GetFinancialInsights(this.repository);

  @override
  Future<Either<Failure, FinancialInsightEntity>> call(NoParams params) async {
    return await repository.getFinancialInsights();
  }
}

