enum ActivityType { registration, allocation, transfer, maintenance, audit }

extension ActivityTypeX on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.registration:
        return 'Registration';
      case ActivityType.allocation:
        return 'Allocation';
      case ActivityType.transfer:
        return 'Transfer';
      case ActivityType.maintenance:
        return 'Maintenance';
      case ActivityType.audit:
        return 'Audit';
    }
  }
}

class RecentActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;

  const RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
  });
}
