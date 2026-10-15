import 'package:equatable/equatable.dart';

enum MessageSender { user, bot, system }

/// Entidade de Domínio representando uma mensagem no chat com o Assistente de IA.
class ChatMessageEntity extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isToolExecution;
  final String? executedToolName;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isToolExecution = false,
    this.executedToolName,
  });

  bool get isUser => sender == MessageSender.user;

  @override
  List<Object?> get props => [
        id,
        text,
        sender,
        timestamp,
        isToolExecution,
        executedToolName,
      ];
}

