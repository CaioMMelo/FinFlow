import 'package:equatable/equatable.dart';

/// Grupos da Metodologia Orçamentária 50/30/20:
/// - **50% Necessidades Básicas:** Moradia, alimentação essencial, saúde, transporte.
/// - **30% Desejos Pessoais & Estilo de Vida:** Lazer, restaurantes, compras, hobbies.
/// - **20% Investimentos & Metas Financeiras:** Reserva de emergência, aposentadoria, amortizações.
enum BudgetCategoryGroup {
  needs,   // Necessidades (50%)
  wants,   // Desejos (30%)
  savings, // Investimentos / Metas (20%)
}

extension BudgetCategoryGroupExtension on BudgetCategoryGroup {
  String get label {
    switch (this) {
      case BudgetCategoryGroup.needs:
        return 'Necessidades (50%)';
      case BudgetCategoryGroup.wants:
        return 'Desejos & Lazer (30%)';
      case BudgetCategoryGroup.savings:
        return 'Investimentos & Metas (20%)';
    }
  }

  double get targetRatio {
    switch (this) {
      case BudgetCategoryGroup.needs:
        return 0.50;
      case BudgetCategoryGroup.wants:
        return 0.30;
      case BudgetCategoryGroup.savings:
        return 0.20;
    }
  }
}

class BudgetEntity extends Equatable {
  final String id;
  final String name;
  final int targetAmountInCents;
  final int currentAmountInCents;
  final BudgetCategoryGroup categoryGroup;
  final DateTime? deadline;

  const BudgetEntity({
    required this.id,
    required this.name,
    required this.targetAmountInCents,
    this.currentAmountInCents = 0,
    required this.categoryGroup,
    this.deadline,
  });

  /// Percentual de consumo ou alcance do orçamento (0.0 a 1.0 ou superior se excedido)
  double get progressPercentage {
    if (targetAmountInCents == 0) return 0.0;
    return (currentAmountInCents / targetAmountInCents).clamp(0.0, 2.0);
  }

  double get formattedTarget => targetAmountInCents / 100.0;
  double get formattedCurrent => currentAmountInCents / 100.0;

  bool get isExceeded => currentAmountInCents > targetAmountInCents;

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmountInCents,
        currentAmountInCents,
        categoryGroup,
        deadline,
      ];
}

