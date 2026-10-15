import 'package:equatable/equatable.dart';

enum FinancialHealthScore {
  excellent, // 80 - 100
  good,      // 60 - 79
  warning,   // 40 - 59
  critical,  // 0 - 39
}

class MonthlyComparison extends Equatable {
  final String monthLabel;
  final int totalIncomeInCents;
  final int totalExpenseInCents;

  const MonthlyComparison({
    required this.monthLabel,
    required this.totalIncomeInCents,
    required this.totalExpenseInCents,
  });

  double get formattedIncome => totalIncomeInCents / 100.0;
  double get formattedExpense => totalExpenseInCents / 100.0;

  int get netSavingsInCents => totalIncomeInCents - totalExpenseInCents;

  @override
  List<Object?> get props => [monthLabel, totalIncomeInCents, totalExpenseInCents];
}

class FinancialInsightEntity extends Equatable {
  final int healthScore; // 0 a 100
  final FinancialHealthScore healthCategory;
  final double savingsRatePercentage; // % da renda que foi poupada
  final String topExpenseCategory;
  final int topExpenseAmountInCents;
  final String smartAdvice;
  final List<MonthlyComparison> monthlyHistory;

  const FinancialInsightEntity({
    required this.healthScore,
    required this.healthCategory,
    required this.savingsRatePercentage,
    required this.topExpenseCategory,
    required this.topExpenseAmountInCents,
    required this.smartAdvice,
    required this.monthlyHistory,
  });

  @override
  List<Object?> get props => [
        healthScore,
        healthCategory,
        savingsRatePercentage,
        topExpenseCategory,
        topExpenseAmountInCents,
        smartAdvice,
        monthlyHistory,
      ];
}

