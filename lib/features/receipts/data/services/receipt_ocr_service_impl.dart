import 'package:dartz/dartz.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../domain/entities/scanned_receipt_data.dart';
import '../../domain/services/receipt_scanner_service.dart';

/// Implementação de OCR 100% on-device utilizando o Google ML Kit Text Recognition.
///
/// **Relevância Técnica & LGPD:**
/// A imagem do comprovante e o texto extraído NUNCA saem do aparelho do usuário para servidores externos.
/// A inferência roda diretamente na NPU/GPU local do smartphone, garantindo privacidade absoluta e custo zero de infraestrutura.
class ReceiptOcrServiceImpl implements ReceiptScannerService {
  final ImagePicker _picker;
  final TextRecognizer _textRecognizer;

  ReceiptOcrServiceImpl({
    ImagePicker? picker,
    TextRecognizer? textRecognizer,
  })  : _picker = picker ?? ImagePicker(),
        _textRecognizer = textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<Either<Failure, ScannedReceiptData?>> scanReceiptFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) return const Right(null); // Usuário cancelou a foto

      return await _processImageFile(photo.path);
    } catch (e) {
      return Left(DatabaseFailure('Falha ao acessar câmera para OCR: $e'));
    }
  }

  @override
  Future<Either<Failure, ScannedReceiptData?>> scanReceiptFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return const Right(null);

      return await _processImageFile(image.path);
    } catch (e) {
      return Left(DatabaseFailure('Falha ao carregar imagem da galeria: $e'));
    }
  }

  Future<Either<Failure, ScannedReceiptData?>> _processImageFile(String path) async {
    try {
      final inputImage = InputImage.fromFilePath(path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final result = await parseReceiptText(recognizedText.text);
      return result.map((data) => data);
    } catch (e) {
      return Left(DatabaseFailure('Erro no processamento do OCR: $e'));
    }
  }

  @override
  Future<Either<Failure, ScannedReceiptData>> parseReceiptText(String rawText) async {
    try {
      final lines = rawText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        return const Left(ValidationFailure('Nenhum texto legível foi detectado na imagem.'));
      }

      // 1. Extração do Nome do Estabelecimento (Linhas do topo, ignorando termos genéricos)
      String merchant = 'Comprovante / Estabelecimento';
      for (final line in lines.take(4)) {
        final upper = line.toUpperCase();
        if (!upper.contains('CUPOM') &&
            !upper.contains('FISCAL') &&
            !upper.contains('CNPJ') &&
            !upper.contains('EXTRATO') &&
            line.length >= 3) {
          merchant = line;
          break;
        }
      }

      // 2. Extração do Valor Monetário (Total em centavos)
      int detectedAmountInCents = 0;
      final valueRegex = RegExp(r'(?:TOTAL|VALOR|PAGAR|R\$)?\s*[:]?\s*R?\$?\s*(\d{1,4}[.,]\d{2})', caseSensitive: false);

      // Procura primeiro por linhas contendo palavra TOTAL ou VALOR
      for (final line in lines) {
        final upper = line.toUpperCase();
        if (upper.contains('TOTAL') || upper.contains('VALOR')) {
          final match = valueRegex.firstMatch(line);
          if (match != null) {
            final rawNum = match.group(1)!.replaceAll('.', '').replaceAll(',', '.');
            final parsed = double.tryParse(rawNum);
            if (parsed != null && parsed > 0) {
              detectedAmountInCents = (parsed * 100).round();
              break;
            }
          }
        }
      }

      // Se não encontrou linha de TOTAL, varre todas as linhas buscando o maior valor numérico encontrado
      if (detectedAmountInCents == 0) {
        for (final line in lines) {
          final matches = valueRegex.allMatches(line);
          for (final m in matches) {
            final rawNum = m.group(1)!.replaceAll('.', '').replaceAll(',', '.');
            final parsed = double.tryParse(rawNum);
            if (parsed != null) {
              final cents = (parsed * 100).round();
              if (cents > detectedAmountInCents) {
                detectedAmountInCents = cents;
              }
            }
          }
        }
      }

      // 3. Extração da Data
      DateTime detectedDate = DateTime.now();
      final dateRegex = RegExp(r'(\d{2})[/.-](\d{2})[/.-]((?:20)?\d{2})');
      for (final line in lines) {
        final match = dateRegex.firstMatch(line);
        if (match != null) {
          try {
            final day = int.parse(match.group(1)!);
            final month = int.parse(match.group(2)!);
            var year = int.parse(match.group(3)!);
            if (year < 100) year += 2000;
            detectedDate = DateTime(year, month, day);
            break;
          } catch (_) {}
        }
      }

      // 4. Inferência Inteligente da Categoria
      final lowerText = rawText.toLowerCase();
      TransactionCategory inferredCategory = TransactionCategory.other;

      if (lowerText.contains('restaurante') ||
          lowerText.contains('lanchonete') ||
          lowerText.contains('mercado') ||
          lowerText.contains('padaria') ||
          lowerText.contains('ifood') ||
          lowerText.contains('cafe') ||
          lowerText.contains('almoço') ||
          lowerText.contains('refeição')) {
        inferredCategory = TransactionCategory.food;
      } else if (lowerText.contains('farmacia') ||
          lowerText.contains('drogaria') ||
          lowerText.contains('droga') ||
          lowerText.contains('hospital') ||
          lowerText.contains('medico') ||
          lowerText.contains('saude')) {
        inferredCategory = TransactionCategory.health;
      } else if (lowerText.contains('posto') ||
          lowerText.contains('combustivel') ||
          lowerText.contains('gasolina') ||
          lowerText.contains('etanol') ||
          lowerText.contains('uber') ||
          lowerText.contains('99') ||
          lowerText.contains('estacionamento') ||
          lowerText.contains('transporte')) {
        inferredCategory = TransactionCategory.transport;
      } else if (lowerText.contains('cinema') ||
          lowerText.contains('livraria') ||
          lowerText.contains('jogos') ||
          lowerText.contains('teatro') ||
          lowerText.contains('lazer')) {
        inferredCategory = TransactionCategory.leisure;
      }

      return Right(
        ScannedReceiptData(
          merchantName: merchant,
          amountInCents: detectedAmountInCents > 0 ? detectedAmountInCents : 1000,
          date: detectedDate,
          suggestedCategory: inferredCategory,
          rawText: rawText,
        ),
      );
    } catch (e) {
      return Left(DatabaseFailure('Erro ao interpretar texto do recibo: $e'));
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

