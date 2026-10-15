import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {
  const BudgetInitial();
}

class BudgetLoading extends BudgetState {
  const BudgetLoading();
}

class BudgetLoaded extends BudgetState {
  final List<BudgetEntity> budgets;
  final int totalSpentNeedsInCents;
  final int totalSpentWantsInCents;
  final int totalSpentSavingsInCents;

  final int totalTargetNeedsInCents;
  final int totalTargetWantsInCents;
  final int totalTargetSavingsInCents;

  const BudgetLoaded({
    required this.budgets,
    required this.totalSpentNeedsInCents,
    required this.totalSpentWantsInCents,
    required this.totalSpentSavingsInCents,
    required this.totalTargetNeedsInCents,
    required this.totalTargetWantsInCents,
    required this.totalTargetSavingsInCents,
  });

  int get totalOverallSpentInCents =>
      totalSpentNeedsInCents + totalSpentWantsInCents + totalSpentSavingsInCents;

  int get totalOverallTargetInCents =>
      totalTargetNeedsInCents + totalTargetWantsInCents + totalTargetSavingsInCents;

  double get formattedTotalSpent => totalOverallSpentInCents / 100.0;
  double get formattedTotalTarget => totalOverallTargetInCents / 100.0;

  @override
  List<Object?> get props => [
        budgets,
        totalSpentNeedsInCents,
        totalSpentWantsInCents,
        totalSpentSavingsInCents,
        totalTargetNeedsInCents,
        totalTargetWantsInCents,
        totalTargetSavingsInCents,
      ];
}

class BudgetError extends BudgetState {
  final String message;
  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

