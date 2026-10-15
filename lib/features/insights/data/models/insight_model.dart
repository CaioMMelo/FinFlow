import '../../domain/entities/insight_entity.dart';

class FinancialInsightModel extends FinancialInsightEntity {
  const FinancialInsightModel({
    required super.healthScore,
    required super.healthCategory,
    required super.savingsRatePercentage,
    required super.topExpenseCategory,
    required super.topExpenseAmountInCents,
    required super.smartAdvice,
    required super.monthlyHistory,
  });

  factory FinancialInsightModel.fromJson(Map<String, dynamic> json) {
    return FinancialInsightModel(
      healthScore: json['healthScore'] as int,
      healthCategory: FinancialHealthScore.values.firstWhere(
        (e) => e.name == json['healthCategory'],
        orElse: () => FinancialHealthScore.good,
      ),
      savingsRatePercentage: (json['savingsRatePercentage'] as num).toDouble(),
      topExpenseCategory: json['topExpenseCategory'] as String,
      topExpenseAmountInCents: json['topExpenseAmountInCents'] as int,
      smartAdvice: json['smartAdvice'] as String,
      monthlyHistory: (json['monthlyHistory'] as List<dynamic>)
          .map((item) => MonthlyComparison(
                monthLabel: item['monthLabel'] as String,
                totalIncomeInCents: item['totalIncomeInCents'] as int,
                totalExpenseInCents: item['totalExpenseInCents'] as int,
              ))
          .toList(),
    );
  }
}

