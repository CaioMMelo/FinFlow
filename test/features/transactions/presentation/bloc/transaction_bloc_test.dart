import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:finflow/core/usecase/usecase.dart';
import 'package:finflow/features/transactions/domain/entities/transaction_entity.dart';
import 'package:finflow/features/transactions/domain/usecases/add_transaction.dart';
import 'package:finflow/features/transactions/domain/usecases/get_transactions.dart';
import 'package:finflow/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:finflow/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:finflow/features/transactions/presentation/bloc/transaction_state.dart';

class MockGetTransactions extends Mock implements GetTransactions {}
class MockAddTransaction extends Mock implements AddTransaction {}

void main() {
  late TransactionBloc bloc;
  late MockGetTransactions mockGetTransactions;
  late MockAddTransaction mockAddTransaction;

  setUp(() {
    mockGetTransactions = MockGetTransactions();
    mockAddTransaction = MockAddTransaction();
    bloc = TransactionBloc(
      getTransactions: mockGetTransactions,
      addTransaction: mockAddTransaction,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testTransactions = [
    TransactionEntity(
      id: '1',
      title: 'Salário',
      amountInCents: 500000, // R$ 5.000,00
      type: TransactionType.income,
      category: TransactionCategory.salary,
      date: DateTime(2026, 1, 1),
    ),
    TransactionEntity(
      id: '2',
      title: 'Aluguel',
      amountInCents: 150000, // R$ 1.500,00
      type: TransactionType.expense,
      category: TransactionCategory.housing,
      date: DateTime(2026, 1, 2),
    ),
  ];

  test('Estado inicial deve ser TransactionInitial', () {
    expect(bloc.state, equals(const TransactionInitial()));
  });

  blocTest<TransactionBloc, TransactionState>(
    'Deve emitir [TransactionLoading, TransactionLoaded] com métricas corretas de saldo quando GetTransactions obtiver sucesso',
    build: () {
      when(() => mockGetTransactions(const NoParams()))
          .thenAnswer((_) async => Right(testTransactions));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadTransactionsEvent()),
    expect: () => [
      const TransactionLoading(),
      TransactionLoaded(
        transactions: testTransactions,
        totalBalanceInCents: 350000, // R$ 3.500,00
        totalIncomeInCents: 500000,
        totalExpenseInCents: 150000,
      ),
    ],
    verify: (_) {
      verify(() => mockGetTransactions(const NoParams())).called(1);
    },
  );
}

