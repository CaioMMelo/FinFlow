import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import 'ai_assistant_event.dart';
import 'ai_assistant_state.dart';

class AiAssistantBloc extends Bloc<AiAssistantEvent, AiAssistantState> {
  final SendAiMessage sendAiMessage;
  final AiAssistantRepository repository;

  AiAssistantBloc({
    required this.sendAiMessage,
    required this.repository,
  }) : super(const AiAssistantInitial()) {
    on<SendPromptEvent>(_onSendPrompt);
    on<ClearConversationEvent>(_onClearConversation);
  }

  Future<void> _onSendPrompt(
    SendPromptEvent event,
    Emitter<AiAssistantState> emit,
  ) async {
    final currentHistory = repository.getMessageHistory();

    // Emite estado com pensamento ativo
    emit(AiAssistantConversation(
      messages: List.from(currentHistory),
      isThinking: true,
    ));

    final result = await sendAiMessage(event.prompt);

    result.fold(
      (failure) => emit(AiAssistantConversation(
        messages: List.from(repository.getMessageHistory()),
        isThinking: false,
        errorMessage: failure.message,
      )),
      (_) => emit(AiAssistantConversation(
        messages: List.from(repository.getMessageHistory()),
        isThinking: false,
      )),
    );
  }

  void _onClearConversation(
    ClearConversationEvent event,
    Emitter<AiAssistantState> emit,
  ) {
    repository.clearHistory();
    emit(const AiAssistantInitial());
  }
}

