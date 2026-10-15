import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message_entity.dart';

abstract class AiAssistantRepository {
  Future<Either<Failure, ChatMessageEntity>> sendMessage(String prompt);
  List<ChatMessageEntity> getMessageHistory();
  void clearHistory();
}

