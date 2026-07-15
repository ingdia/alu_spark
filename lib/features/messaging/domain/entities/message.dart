enum MessageType { text, system, interview, offer, attachment }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;
  final bool isRead;
  final List<String> readBy;
  final MessageType type;
  final String? attachmentUrl;
  final String? attachmentName;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
    this.isRead = false,
    this.readBy = const [],
    this.type = MessageType.text,
    this.attachmentUrl,
    this.attachmentName,
  });

  Message copyWith({
    bool? isRead,
    List<String>? readBy,
  }) =>
      Message(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
        readBy: readBy ?? this.readBy,
        type: type,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
      );
}
