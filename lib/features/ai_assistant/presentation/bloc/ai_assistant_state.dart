import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class AiAssistantState extends Equatable {
  final List<ChatMessageEntity> messages;
  final bool isThinking;
  final String? errorMessage;

  const AiAssistantState({
    this.messages = const [],
    this.isThinking = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [messages, isThinking, errorMessage];
}

class AiAssistantInitial extends AiAssistantState {
  const AiAssistantInitial() : super(messages: const []);
}

class AiAssistantConversation extends AiAssistantState {
  const AiAssistantConversation({
    required super.messages,
    super.isThinking = false,
    super.errorMessage,
  });
}

