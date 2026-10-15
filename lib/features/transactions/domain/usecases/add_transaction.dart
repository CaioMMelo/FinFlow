import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction implements UseCase<void, TransactionEntity> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(TransactionEntity transaction) async {
    // Validação de regra de negócio: valor precisa ser maior que zero
    if (transaction.amountInCents <= 0) {
      return const Left(ValidationFailure('O valor da transação deve ser estritamente maior que zero.'));
    }
    if (transaction.title.trim().isEmpty) {
      return const Left(ValidationFailure('O título da transação é obrigatório.'));
    }

    return await repository.addTransaction(transaction);
  }
}

