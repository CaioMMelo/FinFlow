import '../../domain/entities/transaction_entity.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getLastTransactions();
  Future<void> cacheTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

/// Implementação com armazenamento em memória e dados iniciais simulados para teste imediato.
/// Na próxima etapa, o Drift/SQLCipher substitui a persistência mantendo a mesma interface.
class InMemoryTransactionLocalDataSource implements TransactionLocalDataSource {
  final List<TransactionModel> _storage = [
    TransactionModel(
      id: '1',
      title: 'Salário / Bolsa Estágio',
      description: 'Secretaria de Estado do RJ',
      amountInCents: 250000, // R$ 2.500,00
      type: TransactionType.income,
      category: TransactionCategory.salary,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    TransactionModel(
      id: '2',
      title: 'Almoço no Centro',
      description: 'Restaurante perto da Secretaria',
      amountInCents: 3850, // R$ 38,50
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    TransactionModel(
      id: '3',
      title: 'Metrô Rio',
      description: 'Recarga Bilhete Único',
      amountInCents: 8600, // R$ 86,00
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<TransactionModel>> getLastTransactions() async {
    // Simula pequeno delay de leitura em disco
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _storage.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(_storage);
  }

  @override
  Future<void> cacheTransaction(TransactionModel transaction) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _storage.removeWhere((item) => item.id == transaction.id);
    _storage.add(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    _storage.removeWhere((item) => item.id == id);
  }
}

