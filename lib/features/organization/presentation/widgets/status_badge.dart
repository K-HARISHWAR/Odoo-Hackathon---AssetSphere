import 'package:flutter/material.dart';
import 'package:assetsphere/features/organization/domain/entities/record_status.dart';

class StatusBadge extends StatelessWidget {
  final RecordStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == RecordStatus.active;
    final color = isActive ? Colors.green : Colors.grey;
    final text = isActive ? 'Active' : 'Inactive';
    final bgColor = color.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
