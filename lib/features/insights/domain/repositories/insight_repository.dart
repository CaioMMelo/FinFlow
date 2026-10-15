import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/insight_entity.dart';

abstract class InsightRepository {
  Future<Either<Failure, FinancialInsightEntity>> getFinancialInsights();
}

