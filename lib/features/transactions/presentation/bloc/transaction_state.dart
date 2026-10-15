import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final int totalBalanceInCents;
  final int totalIncomeInCents;
  final int totalExpenseInCents;

  const TransactionLoaded({
    required this.transactions,
    required this.totalBalanceInCents,
    required this.totalIncomeInCents,
    required this.totalExpenseInCents,
  });

  double get formattedBalance => totalBalanceInCents / 100.0;
  double get formattedIncome => totalIncomeInCents / 100.0;
  double get formattedExpense => totalExpenseInCents / 100.0;

  @override
  List<Object?> get props => [
        transactions,
        totalBalanceInCents,
        totalIncomeInCents,
        totalExpenseInCents,
      ];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

