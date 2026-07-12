class DashboardKPI {
  final String title;
  final String value;
  final String? subtitle;
  final double? trend; // Positive for up, negative for down

  const DashboardKPI({
    required this.title,
    required this.value,
    this.subtitle,
    this.trend,
  });
}
