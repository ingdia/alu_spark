enum ApplicationStatus {
  applied,
  underReview,
  interview,
  accepted,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  /// The value written to / read from Firestore.
  String get firestoreValue {
    switch (this) {
      case ApplicationStatus.applied:
        return 'applied';
      case ApplicationStatus.underReview:
        return 'underReview';
      case ApplicationStatus.interview:
        return 'interview';
      case ApplicationStatus.accepted:
        return 'accepted';
      case ApplicationStatus.rejected:
        return 'rejected';
      case ApplicationStatus.withdrawn:
        return 'withdrawn';
    }
  }

  /// Parses a Firestore string, including legacy values written before the rename.
  static ApplicationStatus fromFirestore(String? value) {
    switch (value) {
      case 'applied':
      case 'pending': // legacy
        return ApplicationStatus.applied;
      case 'underReview':
      case 'reviewing': // legacy
        return ApplicationStatus.underReview;
      case 'interview':
        return ApplicationStatus.interview;
      case 'accepted':
        return ApplicationStatus.accepted;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.applied;
    }
  }

  /// Returns true if the student can withdraw from this status.
  bool get canWithdraw =>
      this == applied || this == underReview || this == interview;

  /// Returns true if no further transitions are possible.
  bool get isTerminal =>
      this == accepted || this == rejected || this == withdrawn;

  /// Valid next statuses reachable from this status.
  /// Used by the repository to enforce transition rules.
  Set<ApplicationStatus> get validTransitions {
    switch (this) {
      case ApplicationStatus.applied:
        return {underReview, rejected, withdrawn};
      case ApplicationStatus.underReview:
        return {interview, rejected, withdrawn};
      case ApplicationStatus.interview:
        return {accepted, rejected, withdrawn};
      case ApplicationStatus.accepted:
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return {};
    }
  }

  bool canTransitionTo(ApplicationStatus next) =>
      validTransitions.contains(next);
}
