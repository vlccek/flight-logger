class RoutePoint {
  final double latitude;
  final double longitude;

  RoutePoint({required this.latitude, required this.longitude});

  // Helper methods for JSON conversion.
  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      latitude: json['lat'] as double,
      longitude: json['lon'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': latitude, 'lon': longitude};
  }
}
