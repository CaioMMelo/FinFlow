import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    super.description,
    required super.amountInCents,
    required super.type,
    required super.category,
    required super.date,
    super.isRecurring,
    super.receiptPath,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      amountInCents: json['amountInCents'] as int,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TransactionCategory.other,
      ),
      date: DateTime.parse(json['date'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      receiptPath: json['receiptPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amountInCents': amountInCents,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'receiptPath': receiptPath,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      amountInCents: entity.amountInCents,
      type: entity.type,
      category: entity.category,
      date: entity.date,
      isRecurring: entity.isRecurring,
      receiptPath: entity.receiptPath,
    );
  }
}

