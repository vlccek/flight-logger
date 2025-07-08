// lib/models/api/flight_api_response.dart

// This is the main data class that holds the most important information.
class ApiFlightData {
  final DateTime flightDate;
  final String flightStatus;
  final ApiAirportInfo departure;
  final ApiAirportInfo arrival;
  final ApiAirlineInfo airline;
  final ApiFlightInfo flightInfo;
  final ApiAircraftInfo? aircraft;

  ApiFlightData({
    required this.flightDate,
    required this.flightStatus,
    required this.departure,
    required this.arrival,
    required this.airline,
    required this.flightInfo,
    this.aircraft,
  });

  factory ApiFlightData.fromJson(Map<String, dynamic> json) {
    return ApiFlightData(
      flightDate: DateTime.parse(json['flight_date']),
      flightStatus: json['flight_status'] as String,
      departure: ApiAirportInfo.fromJson(
        json['departure'] as Map<String, dynamic>,
      ),
      arrival: ApiAirportInfo.fromJson(json['arrival'] as Map<String, dynamic>),
      airline: ApiAirlineInfo.fromJson(json['airline'] as Map<String, dynamic>),
      flightInfo: ApiFlightInfo.fromJson(
        json['flight'] as Map<String, dynamic>,
      ),
      aircraft: json['aircraft'] == null
          ? null
          : ApiAircraftInfo.fromJson(json['aircraft'] as Map<String, dynamic>),
    );
  }
}

// Helper classes for nested JSON objects
class ApiAirportInfo {
  final String iata;
  final String icao;
  final DateTime scheduledTime;
  final DateTime? actualTime;

  ApiAirportInfo({
    required this.iata,
    required this.icao,
    required this.scheduledTime,
    this.actualTime,
  });

  factory ApiAirportInfo.fromJson(Map<String, dynamic> json) {
    return ApiAirportInfo(
      iata: json['iata'] as String,
      icao: json['icao'] as String,
      scheduledTime: DateTime.parse(json['scheduled'] as String),
      actualTime: json['actual'] == null
          ? null
          : DateTime.parse(json['actual'] as String),
    );
  }
}

class ApiAirlineInfo {
  final String name;

  ApiAirlineInfo({required this.name});

  factory ApiAirlineInfo.fromJson(Map<String, dynamic> json) =>
      ApiAirlineInfo(name: json['name'] as String);
}

class ApiFlightInfo {
  final String number;

  ApiFlightInfo({required this.number});

  factory ApiFlightInfo.fromJson(Map<String, dynamic> json) =>
      ApiFlightInfo(number: json['number'] as String);
}

class ApiAircraftInfo {
  final String? registration;
  final String? type; // This would be the ICAO type like 'A321'
  ApiAircraftInfo({this.registration, this.type});

  factory ApiAircraftInfo.fromJson(Map<String, dynamic> json) {
    return ApiAircraftInfo(
      registration: json['registration'] as String?,
      type:
          json['icao'] as String?, // The API often provides the ICAO type code
    );
  }
}
