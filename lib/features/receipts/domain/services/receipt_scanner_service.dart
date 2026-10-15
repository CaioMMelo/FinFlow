import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/scanned_receipt_data.dart';

abstract class ReceiptScannerService {
  /// Executa o fluxo de captura (Câmera ou Galeria) e processa o texto via OCR local
  Future<Either<Failure, ScannedReceiptData?>> scanReceiptFromCamera();
  Future<Either<Failure, ScannedReceiptData?>> scanReceiptFromGallery();
  Future<Either<Failure, ScannedReceiptData>> parseReceiptText(String rawText);
}

