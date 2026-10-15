import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/get_budgets.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgets getBudgets;
  final CreateBudget createBudget;

  BudgetBloc({
    required this.getBudgets,
    required this.createBudget,
  }) : super(const BudgetInitial()) {
    on<LoadBudgetsEvent>(_onLoadBudgets);
    on<CreateBudgetEvent>(_onCreateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
  }

  Future<void> _onLoadBudgets(
    LoadBudgetsEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(const BudgetLoading());
    final result = await getBudgets(const NoParams());

    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) {
        int spentNeeds = 0;
        int spentWants = 0;
        int spentSavings = 0;

        int targetNeeds = 0;
        int targetWants = 0;
        int targetSavings = 0;

        for (final b in budgets) {
          switch (b.categoryGroup) {
            case BudgetCategoryGroup.needs:
              spentNeeds += b.currentAmountInCents;
              targetNeeds += b.targetAmountInCents;
              break;
            case BudgetCategoryGroup.wants:
              spentWants += b.currentAmountInCents;
              targetWants += b.targetAmountInCents;
              break;
            case BudgetCategoryGroup.savings:
              spentSavings += b.currentAmountInCents;
              targetSavings += b.targetAmountInCents;
              break;
          }
        }

        emit(BudgetLoaded(
          budgets: budgets,
          totalSpentNeedsInCents: spentNeeds,
          totalSpentWantsInCents: spentWants,
          totalSpentSavingsInCents: spentSavings,
          totalTargetNeedsInCents: targetNeeds,
          totalTargetWantsInCents: targetWants,
          totalTargetSavingsInCents: targetSavings,
        ));
      },
    );
  }

  Future<void> _onCreateBudget(
    CreateBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    final result = await createBudget(event.budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) => add(const LoadBudgetsEvent()),
    );
  }

  Future<void> _onDeleteBudget(
    DeleteBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    add(const LoadBudgetsEvent());
  }
}

