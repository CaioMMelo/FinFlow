import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  final AddTransaction addTransaction;

  TransactionBloc({
    required this.getTransactions,
    required this.addTransaction,
  }) : super(const TransactionInitial()) {
    on<LoadTransactionsEvent>(_onLoadTransactions);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    final result = await getTransactions(const NoParams());

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (transactions) {
        int income = 0;
        int expense = 0;

        for (final t in transactions) {
          if (t.type == TransactionType.income) {
            income += t.amountInCents;
          } else if (t.type == TransactionType.expense) {
            expense += t.amountInCents;
          }
        }

        emit(TransactionLoaded(
          transactions: transactions,
          totalBalanceInCents: income - expense,
          totalIncomeInCents: income,
          totalExpenseInCents: expense,
        ));
      },
    );
  }

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await addTransaction(event.transaction);

    result.fold(
      (failure) => emit(TransactionError(failure.message)),
      (_) => add(const LoadTransactionsEvent()),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    // Recarrega lista após remoção
    add(const LoadTransactionsEvent());
  }
}

