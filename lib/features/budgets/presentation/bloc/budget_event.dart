import 'package:equatable/equatable.dart';
import '../../domain/entities/budget_entity.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

class LoadBudgetsEvent extends BudgetEvent {
  const LoadBudgetsEvent();
}

class CreateBudgetEvent extends BudgetEvent {
  final BudgetEntity budget;
  const CreateBudgetEvent(this.budget);

  @override
  List<Object?> get props => [budget];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String id;
  const DeleteBudgetEvent(this.id);

  @override
  List<Object?> get props => [id];
}

