import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pendingStartupsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('startups')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((s) {
        final list = s.docs.map((d) => {'id': d.id, ...d.data()}).toList();
        list.sort((a, b) {
          final aTime = a['submittedAt'];
          final bTime = b['submittedAt'];
          if (aTime == null || bTime == null) return 0;
          return (bTime as Timestamp).compareTo(aTime as Timestamp);
        });
        return list;
      });
});

final approvedStartupsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('startups')
      .where('status', isEqualTo: 'approved')
      .snapshots()
      .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
});

class VerificationNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> _refreshToken() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      await fb_auth.FirebaseAuth.instance.currentUser?.getIdToken(true);
    }
  }

  Future<void> approveStartup(String startupId) async {
    state = const AsyncLoading();
    try {
      await _refreshToken();
      final batch = FirebaseFirestore.instance.batch();
      batch.update(
        FirebaseFirestore.instance.collection('startups').doc(startupId),
        {
          'status': 'approved',
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(startupId),
        {
          'role': 'founder',
          'isApproved': true,
          'startupProfileStatus': 'approved',
        },
      );
      await batch.commit();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> rejectStartup(String startupId, {String? reason}) async {
    state = const AsyncLoading();
    try {
      await _refreshToken();
      final batch = FirebaseFirestore.instance.batch();
      batch.update(
        FirebaseFirestore.instance.collection('startups').doc(startupId),
        {
          'status': 'rejected',
          if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
          'reviewedAt': FieldValue.serverTimestamp(),
        },
      );
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(startupId),
        {
          'isApproved': false,
          'startupProfileStatus': 'rejected',
          if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
        },
      );
      await batch.commit();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final verificationNotifierProvider =
    NotifierProvider<VerificationNotifier, AsyncValue<void>>(VerificationNotifier.new);
