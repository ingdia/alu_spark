import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class MessagingState {
  final List<Conversation> conversations;
  final Map<String, List<Message>> messages;

  const MessagingState({
    this.conversations = const [],
    this.messages = const {},
  });

  MessagingState copyWith({
    List<Conversation>? conversations,
    Map<String, List<Message>>? messages,
  }) =>
      MessagingState(
        conversations: conversations ?? this.conversations,
        messages: messages ?? this.messages,
      );
}

// ─── Store ────────────────────────────────────────────────────────────────────

class LocalMessageStore {
  MessagingState _state = const MessagingState();
  final _controller = StreamController<MessagingState>.broadcast();

  MessagingState get state => _state;
  Stream<MessagingState> get stateStream => _controller.stream;

  LocalMessageStore() {
    _seed();
  }

  void _emit(MessagingState next) {
    _state = next;
    _controller.add(next);
  }

  void dispose() => _controller.close();

  // ── Seed realistic dummy data ──────────────────────────────────────────────

  void _seed() {
    final now = DateTime.now();
    DateTime d(int days, [int hours = 0, int minutes = 0]) =>
        now.subtract(Duration(days: days, hours: hours, minutes: minutes));

    const founderId = 'founder_001';
    const founderName = 'Amara Diallo';
    const student1Id = 'student_001';
    const student1Name = 'Kwame Mensah';
    const student2Id = 'student_002';
    const student2Name = 'Fatima Al-Rashid';

    // ── Conversation 1: Interview scheduled ───────────────────────────────
    const conv1Id = 'conv_interview_001';
    final conv1 = Conversation(
      id: conv1Id,
      participantIds: [founderId, student1Id],
      participantNames: {founderId: founderName, student1Id: student1Name},
      participantRoles: {founderId: 'founder', student1Id: 'student'},
      lastMessage: 'Looking forward to speaking with you!',
      lastMessageTime: d(0, 1, 30),
      unreadCounts: {founderId: 0, student1Id: 1},
      opportunityId: 'opp_001',
      opportunityTitle: 'Software Engineering Intern',
      applicationId: 'app_001',
      lastSeen: {founderId: d(0, 0, 5), student1Id: d(0, 2)},
    );

    final msgs1 = <Message>[
      Message(
        id: 'm1_1',
        conversationId: conv1Id,
        senderId: 'system',
        senderName: 'ALU Spark',
        text: 'This conversation was created because $student1Name has been '
            'invited to interview for "Software Engineering Intern".',
        createdAt: d(3),
        type: MessageType.system,
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_2',
        conversationId: conv1Id,
        senderId: founderId,
        senderName: founderName,
        text: '📅 Interview Scheduled\n\nDate: 20 Jan 2026\nTime: 10:00 AM\n'
            'Location: Google Meet\nLink: https://meet.google.com/abc-defg-hij'
            '\n\nPlease confirm your availability.',
        createdAt: d(3, 0, 5),
        type: MessageType.interview,
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_3',
        conversationId: conv1Id,
        senderId: student1Id,
        senderName: student1Name,
        text: "Thank you! I confirm my availability for the 20th at 10 AM. "
            "I'll be prepared.",
        createdAt: d(2, 22),
        type: MessageType.text,
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_4',
        conversationId: conv1Id,
        senderId: founderId,
        senderName: founderName,
        text: "Great! Please come ready to discuss Flutter and state "
            "management. We'll also do a short live coding exercise.",
        createdAt: d(2, 20),
        type: MessageType.text,
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_5',
        conversationId: conv1Id,
        senderId: student1Id,
        senderName: student1Name,
        text: "Understood. I've been reviewing Riverpod patterns. "
            "Should I bring portfolio materials?",
        createdAt: d(1, 18),
        type: MessageType.text,
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_6',
        conversationId: conv1Id,
        senderId: student1Id,
        senderName: student1Name,
        text: '📎 My Portfolio\nhttps://kwame.dev/portfolio',
        createdAt: d(1, 17, 55),
        type: MessageType.attachment,
        attachmentUrl: 'https://kwame.dev/portfolio',
        attachmentName: 'Portfolio — Kwame Mensah',
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_7',
        conversationId: conv1Id,
        senderId: founderId,
        senderName: founderName,
        text: 'Yes, feel free to share your portfolio during the call. '
            'Your GitHub projects look impressive already.',
        createdAt: d(0, 3),
        type: MessageType.text,
        readBy: [founderId, student1Id],
      ),
      Message(
        id: 'm1_8',
        conversationId: conv1Id,
        senderId: student1Id,
        senderName: student1Name,
        text: 'Looking forward to speaking with you!',
        createdAt: d(0, 1, 30),
        type: MessageType.text,
        readBy: [founderId],
      ),
    ];

    // ── Conversation 2: Offer extended ────────────────────────────────────
    const conv2Id = 'conv_offer_002';
    final conv2 = Conversation(
      id: conv2Id,
      participantIds: [founderId, student2Id],
      participantNames: {founderId: founderName, student2Id: student2Name},
      participantRoles: {founderId: 'founder', student2Id: 'student'},
      lastMessage: 'I accept the offer! Thank you so much 🎉',
      lastMessageTime: d(1, 10),
      unreadCounts: {founderId: 1, student2Id: 0},
      opportunityId: 'opp_002',
      opportunityTitle: 'Product Design Intern',
      applicationId: 'app_002',
      lastSeen: {founderId: d(1, 12), student2Id: d(1, 9, 50)},
    );

    final msgs2 = <Message>[
      Message(
        id: 'm2_1',
        conversationId: conv2Id,
        senderId: 'system',
        senderName: 'ALU Spark',
        text: 'This conversation was created because $student2Name has been '
            'invited to interview for "Product Design Intern".',
        createdAt: d(7),
        type: MessageType.system,
        readBy: [founderId, student2Id],
      ),
      Message(
        id: 'm2_2',
        conversationId: conv2Id,
        senderId: founderId,
        senderName: founderName,
        text: '📅 Interview Scheduled\n\nDate: 10 Jan 2026\nTime: 2:00 PM\n'
            'Location: Zoom\nLink: https://zoom.us/j/123456789',
        createdAt: d(7, 0, 10),
        type: MessageType.interview,
        readBy: [founderId, student2Id],
      ),
      Message(
        id: 'm2_3',
        conversationId: conv2Id,
        senderId: student2Id,
        senderName: student2Name,
        text: "Confirmed! I'll be there. Thank you for the opportunity.",
        createdAt: d(6, 20),
        type: MessageType.text,
        readBy: [founderId, student2Id],
      ),
      Message(
        id: 'm2_4',
        conversationId: conv2Id,
        senderId: founderId,
        senderName: founderName,
        text: 'The interview went really well, Fatima. The team was very '
            'impressed with your Figma work.',
        createdAt: d(4),
        type: MessageType.text,
        readBy: [founderId, student2Id],
      ),
      Message(
        id: 'm2_5',
        conversationId: conv2Id,
        senderId: founderId,
        senderName: founderName,
        text: '🎉 Offer Extended\n\nWe are pleased to offer you the Product '
            'Design Intern position at TechVentures Africa.\n\n'
            'Start Date: 1 Feb 2026\nDuration: 3 months\nStipend: \$500/month'
            '\n\nPlease confirm your acceptance.',
        createdAt: d(3, 14),
        type: MessageType.offer,
        readBy: [founderId, student2Id],
      ),
      Message(
        id: 'm2_6',
        conversationId: conv2Id,
        senderId: student2Id,
        senderName: student2Name,
        text: 'I accept the offer! Thank you so much 🎉',
        createdAt: d(1, 10),
        type: MessageType.text,
        readBy: [student2Id],
      ),
    ];

    _emit(MessagingState(
      conversations: [conv1, conv2],
      messages: {conv1Id: msgs1, conv2Id: msgs2},
    ));
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  void addMessage(Message msg) {
    final convId = msg.conversationId;
    final msgs = Map<String, List<Message>>.from(_state.messages);
    msgs[convId] = [...(msgs[convId] ?? []), msg];

    final convs = _state.conversations.map((c) {
      if (c.id != convId) return c;
      final unread = Map<String, int>.from(c.unreadCounts);
      for (final pid in c.participantIds) {
        if (pid != msg.senderId) unread[pid] = (unread[pid] ?? 0) + 1;
      }
      return c.copyWith(
        lastMessage: _preview(msg),
        lastMessageTime: msg.createdAt,
        unreadCounts: unread,
      );
    }).toList();

    _emit(_state.copyWith(conversations: convs, messages: msgs));
  }

  void markRead(String convId, String userId) {
    final convs = _state.conversations.map((c) {
      if (c.id != convId) return c;
      final unread = Map<String, int>.from(c.unreadCounts);
      unread[userId] = 0;
      return c.copyWith(unreadCounts: unread);
    }).toList();

    final msgs = Map<String, List<Message>>.from(_state.messages);
    msgs[convId] = (msgs[convId] ?? []).map((m) {
      if (m.readBy.contains(userId)) return m;
      return m.copyWith(readBy: [...m.readBy, userId]);
    }).toList();

    _emit(_state.copyWith(conversations: convs, messages: msgs));
  }

  void setTyping(String convId, String userId, bool typing) {
    final convs = _state.conversations.map((c) {
      if (c.id != convId) return c;
      final list = List<String>.from(c.typingUsers);
      if (typing && !list.contains(userId)) list.add(userId);
      if (!typing) list.remove(userId);
      return c.copyWith(typingUsers: list);
    }).toList();
    _emit(_state.copyWith(conversations: convs));
  }

  void updateLastSeen(String convId, String userId) {
    final convs = _state.conversations.map((c) {
      if (c.id != convId) return c;
      final ls = Map<String, DateTime>.from(c.lastSeen);
      ls[userId] = DateTime.now();
      return c.copyWith(lastSeen: ls);
    }).toList();
    _emit(_state.copyWith(conversations: convs));
  }

  String upsertConversation({
    required String userId1,
    required String name1,
    required String userId2,
    required String name2,
    String? opportunityId,
    String? opportunityTitle,
    String? applicationId,
    String role1 = 'founder',
    String role2 = 'student',
  }) {
    final ids = [userId1, userId2]..sort();
    final convId = '${ids[0]}_${ids[1]}';
    if (_state.conversations.any((c) => c.id == convId)) return convId;

    final conv = Conversation(
      id: convId,
      participantIds: [userId1, userId2],
      participantNames: {userId1: name1, userId2: name2},
      participantRoles: {userId1: role1, userId2: role2},
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      unreadCounts: {userId1: 0, userId2: 0},
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      applicationId: applicationId,
      lastSeen: const {},
      typingUsers: const [],
    );
    _emit(_state.copyWith(conversations: [conv, ..._state.conversations]));
    return convId;
  }

  String _preview(Message m) {
    switch (m.type) {
      case MessageType.system:
        return '🔔 ${m.text.length > 60 ? '${m.text.substring(0, 60)}…' : m.text}';
      case MessageType.interview:
        return '📅 Interview details';
      case MessageType.offer:
        return '🎉 Offer extended';
      case MessageType.attachment:
        return '📎 ${m.attachmentName ?? 'Attachment'}';
      case MessageType.text:
        return m.text.length > 60 ? '${m.text.substring(0, 60)}…' : m.text;
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final localMessageStoreProvider = Provider<LocalMessageStore>((ref) {
  final store = LocalMessageStore();
  ref.onDispose(store.dispose);
  return store;
});
