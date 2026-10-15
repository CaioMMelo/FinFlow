import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/insight_entity.dart';
import '../../domain/repositories/insight_repository.dart';
import '../datasources/insight_local_datasource.dart';

class InsightRepositoryImpl implements InsightRepository {
  final InsightLocalDataSource localDataSource;

  InsightRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, FinancialInsightEntity>> getFinancialInsights() async {
    try {
      final model = await localDataSource.computeInsights();
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao processar insights financeiros: $e'));
    }
  }
}

