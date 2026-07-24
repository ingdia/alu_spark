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
  final List<String> deliveredTo;
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
    this.deliveredTo = const [],
    this.type = MessageType.text,
    this.attachmentUrl,
    this.attachmentName,
  });

  /// Sent = in Firestore. Delivered = recipient device received it. Read = recipient opened chat.
  bool get isDelivered => deliveredTo.isNotEmpty;

  Message copyWith({
    bool? isRead,
    List<String>? readBy,
    List<String>? deliveredTo,
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
        deliveredTo: deliveredTo ?? this.deliveredTo,
        type: type,
        attachmentUrl: attachmentUrl,
        attachmentName: attachmentName,
      );
}
