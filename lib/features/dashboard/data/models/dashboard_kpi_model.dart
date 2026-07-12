import '../../domain/entities/dashboard_kpi.dart';

class DashboardKPIModel extends DashboardKPI {
  const DashboardKPIModel({
    required super.title,
    required super.value,
    super.subtitle,
    super.trend,
  });

  factory DashboardKPIModel.fromJson(Map<String, dynamic> json) {
    return DashboardKPIModel(
      title: json['title'],
      value: json['value'],
      subtitle: json['subtitle'],
      trend: (json['trend'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'value': value,
      'subtitle': subtitle,
      'trend': trend,
    };
  }
}
