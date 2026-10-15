import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../datasources/gemini_ai_remote_datasource.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  final GeminiAiRemoteDataSource remoteDataSource;

  AiAssistantRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage(String prompt) async {
    try {
      final response = await remoteDataSource.processUserMessage(prompt);
      return Right(response);
    } catch (e) {
      return Left(DatabaseFailure('Erro ao se comunicar com o assistente Gemini: $e'));
    }
  }

  @override
  List<ChatMessageEntity> getMessageHistory() {
    return remoteDataSource.getHistory();
  }

  @override
  void clearHistory() {
    remoteDataSource.clearHistory();
  }
}

