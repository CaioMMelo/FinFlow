import '../models/budget_model.dart';
import '../../domain/entities/budget_entity.dart';

abstract class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<void> saveBudget(BudgetModel budget);
  Future<void> deleteBudget(String id);
  Future<void> updateSpending(String id, int amountInCents);
}

class InMemoryBudgetLocalDataSource implements BudgetLocalDataSource {
  final List<BudgetModel> _budgets = [
    const BudgetModel(
      id: 'b1',
      name: 'Moradia & Contas Fixas',
      targetAmountInCents: 120000, // R$ 1.200,00
      currentAmountInCents: 95000,  // R$ 950,00 (79%)
      categoryGroup: BudgetCategoryGroup.needs,
    ),
    const BudgetModel(
      id: 'b2',
      name: 'Alimentação & Supermercado',
      targetAmountInCents: 80000,  // R$ 800,00
      currentAmountInCents: 62000,  // R$ 620,00 (77.5%)
      categoryGroup: BudgetCategoryGroup.needs,
    ),
    const BudgetModel(
      id: 'b3',
      name: 'Restaurantes & Lazer no FDS',
      targetAmountInCents: 50000,  // R$ 500,00
      currentAmountInCents: 38000,  // R$ 380,00 (76%)
      categoryGroup: BudgetCategoryGroup.wants,
    ),
    const BudgetModel(
      id: 'b4',
      name: 'Reserva de Emergência Tesouro Selic',
      targetAmountInCents: 60000,  // R$ 600,00
      currentAmountInCents: 60000,  // R$ 600,00 (100% atingido!)
      categoryGroup: BudgetCategoryGroup.savings,
    ),
  ];

  @override
  Future<List<BudgetModel>> getBudgets() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    return List.unmodifiable(_budgets);
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _budgets.removeWhere((b) => b.id == budget.id);
    _budgets.add(budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _budgets.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> updateSpending(String id, int amountInCents) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      final existing = _budgets[index];
      _budgets[index] = BudgetModel(
        id: existing.id,
        name: existing.name,
        targetAmountInCents: existing.targetAmountInCents,
        currentAmountInCents: existing.currentAmountInCents + amountInCents,
        categoryGroup: existing.categoryGroup,
        deadline: existing.deadline,
      );
    }
  }
}

