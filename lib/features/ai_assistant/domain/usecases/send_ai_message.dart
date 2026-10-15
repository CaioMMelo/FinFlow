import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/ai_assistant_repository.dart';

class SendAiMessage implements UseCase<ChatMessageEntity, String> {
  final AiAssistantRepository repository;

  SendAiMessage(this.repository);

  @override
  Future<Either<Failure, ChatMessageEntity>> call(String prompt) async {
    if (prompt.trim().isEmpty) {
      return const Left(ValidationFailure('A mensagem não pode ser vazia.'));
    }
    return await repository.sendMessage(prompt);
  }
}

