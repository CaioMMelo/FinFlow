import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:finflow/core/usecase/usecase.dart';
import 'package:finflow/features/budgets/domain/entities/budget_entity.dart';
import 'package:finflow/features/budgets/domain/usecases/create_budget.dart';
import 'package:finflow/features/budgets/domain/usecases/get_budgets.dart';
import 'package:finflow/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:finflow/features/budgets/presentation/bloc/budget_event.dart';
import 'package:finflow/features/budgets/presentation/bloc/budget_state.dart';

class MockGetBudgets extends Mock implements GetBudgets {}
class MockCreateBudget extends Mock implements CreateBudget {}

void main() {
  late BudgetBloc bloc;
  late MockGetBudgets mockGetBudgets;
  late MockCreateBudget mockCreateBudget;

  setUp(() {
    mockGetBudgets = MockGetBudgets();
    mockCreateBudget = MockCreateBudget();
    bloc = BudgetBloc(
      getBudgets: mockGetBudgets,
      createBudget: mockCreateBudget,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testBudgets = [
    const BudgetEntity(
      id: '1',
      name: 'Supermercado',
      targetAmountInCents: 100000, // R$ 1.000,00
      currentAmountInCents: 60000,  // R$ 600,00
      categoryGroup: BudgetCategoryGroup.needs,
    ),
    const BudgetEntity(
      id: '2',
      name: 'Lazer',
      targetAmountInCents: 40000,  // R$ 400,00
      currentAmountInCents: 20000,  // R$ 200,00
      categoryGroup: BudgetCategoryGroup.wants,
    ),
  ];

  test('Estado inicial deve ser BudgetInitial', () {
    expect(bloc.state, equals(const BudgetInitial()));
  });

  blocTest<BudgetBloc, BudgetState>(
    'Deve emitir [BudgetLoading, BudgetLoaded] agregando valores por categoria da regra 50/30/20 quando GetBudgets tiver sucesso',
    build: () {
      when(() => mockGetBudgets(const NoParams()))
          .thenAnswer((_) async => Right(testBudgets));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadBudgetsEvent()),
    expect: () => [
      const BudgetLoading(),
      BudgetLoaded(
        budgets: testBudgets,
        totalSpentNeedsInCents: 60000,
        totalSpentWantsInCents: 20000,
        totalSpentSavingsInCents: 0,
        totalTargetNeedsInCents: 100000,
        totalTargetWantsInCents: 40000,
        totalTargetSavingsInCents: 0,
      ),
    ],
    verify: (_) {
      verify(() => mockGetBudgets(const NoParams())).called(1);
    },
  );
}

