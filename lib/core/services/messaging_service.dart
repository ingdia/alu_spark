import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/features/messaging/domain/entities/conversation.dart';
import 'package:alu_spark/features/messaging/domain/entities/message.dart';
import 'package:alu_spark/features/messaging/domain/repositories/message_repository.dart';
import 'package:alu_spark/features/messaging/data/repositories/message_repository_impl.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class MessagingService {
  final MessageRepository _messageRepository;
  final FirebaseFirestore _firestore;

  MessagingService({
    MessageRepository? messageRepository,
    FirebaseFirestore? firestore,
  })  : _messageRepository = messageRepository ?? MessageRepositoryImpl(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get or create a conversation with proper user names
  Future<String> startConversation({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    String? opportunityId,
  }) async {
    final conversationId = await _messageRepository.getOrCreateConversation(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
    );

    // Update conversation with opportunity ID if provided
    if (opportunityId != null) {
      await _firestore.collection('conversations').doc(conversationId).update({
        'opportunityId': opportunityId,
      });
    }

    return conversationId;
  }

  /// Send a message with sender name
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final message = Message(
      id: '',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      createdAt: DateTime.now(),
      isRead: false,
      readBy: const [],
    );

    await _messageRepository.sendMessage(message);
  }

  /// Mark conversation as read for current user
  Future<void> markConversationAsRead(String conversationId, String userId) async {
    await _messageRepository.markAsRead(conversationId, userId);
  }

  /// Get conversations list for a user
  Stream<List<Conversation>> getConversations(String userId) {
    return _messageRepository.getConversations(userId);
  }

  /// Get messages for a conversation
  Stream<List<Message>> getMessages(String conversationId) {
    return _messageRepository.getMessages(conversationId);
  }

  /// Check if two users can message each other
  /// Students can only message startups they've applied to
  /// Startups can message students who applied to their opportunities
  Future<bool> canMessage(User currentUser, User otherUser) async {
    // Admins can message anyone
    if (currentUser.role == UserRole.admin || otherUser.role == UserRole.admin) {
      return true;
    }

    // Same role cannot message each other
    if (currentUser.role == otherUser.role) {
      return false;
    }

    // If student, check if they have an application to startup's opportunity
    if (currentUser.role == UserRole.student && otherUser.role == UserRole.founder) {
      final applications = await _firestore
          .collection('applications')
          .where('studentId', isEqualTo: currentUser.id)
          .where('startupId', isEqualTo: otherUser.id)
          .limit(1)
          .get();

      return applications.docs.isNotEmpty;
    }

    // If founder, check if student has applied to their opportunity
    if (currentUser.role == UserRole.founder && otherUser.role == UserRole.student) {
      final applications = await _firestore
          .collection('applications')
          .where('studentId', isEqualTo: otherUser.id)
          .where('startupId', isEqualTo: currentUser.id)
          .limit(1)
          .get();

      return applications.docs.isNotEmpty;
    }

    return false;
  }

  /// Get conversation participants with their names
  Future<Map<String, String>> getParticipantNames(String conversationId) async {
    final doc = await _firestore.collection('conversations').doc(conversationId).get();
    
    if (!doc.exists) {
      return {};
    }

    final data = doc.data() ?? {};
    return Map<String, String>.from(data['participantNames'] ?? {});
  }

  /// Get user information by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        return null;
      }

      return User.fromMap(doc.data()!..addAll({'id': doc.id}));
    } catch (e) {
      return null;
    }
  }

  /// Get unread message count across all conversations
  Future<int> getTotalUnreadCount(String userId) async {
    final conversations = await _messageRepository.getConversations(userId).first;
    
    int total = 0;
    for (final conv in conversations) {
      total += conv.getUnreadCount(userId);
    }
    
    return total;
  }
}