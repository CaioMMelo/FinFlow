import '../models/insight_model.dart';
import '../../domain/entities/insight_entity.dart';

abstract class InsightLocalDataSource {
  Future<FinancialInsightModel> computeInsights();
}

class InMemoryInsightLocalDataSource implements InsightLocalDataSource {
  @override
  Future<FinancialInsightModel> computeInsights() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return const FinancialInsightModel(
      healthScore: 84,
      healthCategory: FinancialHealthScore.excellent,
      savingsRatePercentage: 32.5, // 32.5% da renda poupada
      topExpenseCategory: 'Alimentação & Restaurantes',
      topExpenseAmountInCents: 62000, // R$ 620,00
      smartAdvice:
          'Parabéns! Sua taxa de poupança está acima da média recomendada de 20%. Dica de economia: reduzindo 10% nos jantares fora, você antecipará sua meta de reserva em 2 meses.',
      monthlyHistory: [
        MonthlyComparison(
          monthLabel: 'Ago',
          totalIncomeInCents: 240000,
          totalExpenseInCents: 185000,
        ),
        MonthlyComparison(
          monthLabel: 'Set',
          totalIncomeInCents: 250000,
          totalExpenseInCents: 172000,
        ),
        MonthlyComparison(
          monthLabel: 'Out',
          totalIncomeInCents: 250000,
          totalExpenseInCents: 155000,
        ),
      ],
    );
  }
}

