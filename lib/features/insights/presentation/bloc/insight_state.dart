import 'package:equatable/equatable.dart';
import '../../domain/entities/insight_entity.dart';

abstract class InsightState extends Equatable {
  const InsightState();

  @override
  List<Object?> get props => [];
}

class InsightInitial extends InsightState {
  const InsightInitial();
}

class InsightLoading extends InsightState {
  const InsightLoading();
}

class InsightLoaded extends InsightState {
  final FinancialInsightEntity insights;

  const InsightLoaded(this.insights);

  @override
  List<Object?> get props => [insights];
}

class InsightError extends InsightState {
  final String message;
  const InsightError(this.message);

  @override
  List<Object?> get props => [message];
}

