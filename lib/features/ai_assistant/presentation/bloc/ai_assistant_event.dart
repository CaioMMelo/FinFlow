import 'package:equatable/equatable.dart';

abstract class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

class SendPromptEvent extends AiAssistantEvent {
  final String prompt;
  const SendPromptEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

class ClearConversationEvent extends AiAssistantEvent {
  const ClearConversationEvent();
}

