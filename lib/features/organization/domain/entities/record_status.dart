enum RecordStatus { active, inactive }

extension RecordStatusX on RecordStatus {
  String get displayName {
    switch (this) {
      case RecordStatus.active:
        return 'Active';
      case RecordStatus.inactive:
        return 'Inactive';
    }
  }
}
