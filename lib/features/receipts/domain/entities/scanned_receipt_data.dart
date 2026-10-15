import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

/// Dados estruturados extraídos automaticamente a partir do processamento OCR de um recibo ou nota fiscal.
class ScannedReceiptData extends Equatable {
  final String merchantName;
  final int amountInCents;
  final DateTime date;
  final TransactionCategory suggestedCategory;
  final String rawText;
  final double confidenceScore;

  const ScannedReceiptData({
    required this.merchantName,
    required this.amountInCents,
    required this.date,
    required this.suggestedCategory,
    required this.rawText,
    this.confidenceScore = 1.0,
  });

  double get formattedAmount => amountInCents / 100.0;

  @override
  List<Object?> get props => [
        merchantName,
        amountInCents,
        date,
        suggestedCategory,
        rawText,
        confidenceScore,
      ];
}

