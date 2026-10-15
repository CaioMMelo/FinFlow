import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer }

enum TransactionCategory {
  salary,
  freelance,
  food,
  transport,
  housing,
  health,
  education,
  leisure,
  investment,
  other,
}

/// Entidade de Domínio que representa uma transação financeira.
///
/// **Regra Arquitetural de Segurança Financeira:**
/// O valor (`amountInCents`) é estritamente armazenado como `int` (centavos) para evitar
/// problemas de arredondamento e perda de precisão de ponto flutuante (`double`).
/// Exemplo: R$ 150,75 é representado como 15075.
class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final int amountInCents;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final bool isRecurring;
  final String? receiptPath;

  const TransactionEntity({
    required this.id,
    required this.title,
    this.description,
    required this.amountInCents,
    required this.type,
    required this.category,
    required this.date,
    this.isRecurring = false,
    this.receiptPath,
  });

  /// Converte o valor em centavos para representação decimal apenas para exibição
  double get formattedAmount => amountInCents / 100.0;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        amountInCents,
        type,
        category,
        date,
        isRecurring,
        receiptPath,
      ];
}

