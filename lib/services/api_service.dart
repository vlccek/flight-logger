import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/secure_storage_service.dart'; // Re-added for API URL
import '../models/airport.dart';
import '../models/flight.dart';
import '../utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  // final AuthService _authService = AuthService(); // This created a circular dependency
  final SecureStorageService _secureStorageService =
      SecureStorageService(); // For API URL

  Future<String> _getBaseUrl() async {
    final url = await _secureStorageService.getApiUrl();
    if (url == null || url.isEmpty) {
      throw Exception('API URL not configured in settings.');
    }
    return url;
  }

  Future<Map<String, String>> _getHeaders() async {
    // Call the singleton instance directly
    final token = await AuthService().getToken();
    if (token == null) {
      // This will be caught by AuthService, but as a safeguard:
      throw Exception('Not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<LoginResponse> login(String email, String password) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register');
    }
  }

  // Airport Endpoints
  Future<List<Airport>> getAirports({
    int? page,
    int? limit,
    String? sortBy,
  }) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final Map<String, String> queryParameters = {};

    if (page != null) {
      queryParameters['page'] = page.toString();
    }
    if (limit != null) {
      queryParameters['limit'] = limit.toString();
    }
    if (sortBy != null) {
      queryParameters['sortBy'] = sortBy;
    }

    final uri = Uri.parse('$baseUrl/api/v1/airports').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Airport.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load airports');
    }
  }

  Future<Airport> getAirportById(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/airports/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Airport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load airport');
    }
  }

  Future<Airport> createAirport(Airport airport) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/airports'),
      headers: headers,
      body: jsonEncode(airport.toJson()),
    );

    if (response.statusCode == 200) {
      return Airport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create airport');
    }
  }

  Future<void> updateAirport(String id, Airport airport) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/airports/$id'),
      headers: headers,
      body: jsonEncode(airport.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update airport');
    }
  }

  Future<void> deleteAirport(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/airports/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete airport');
    }
  }

  // Flight Endpoints
  Future<List<Flight>> getFlights() async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/myflights');
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return [];
      }
      final dynamic decodedData = jsonDecode(response.body);
      if (decodedData == null) {
        return [];
      }
      if (decodedData is List) {
        return decodedData
            .where((item) => item != null) // Filter out null items
            .map((json) => Flight.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // If the response is not a list, return an empty list or throw a more specific error
        throw Exception(
          'API response for flights was not a list: ${response.body}',
        );
      }
    } else {
      throw Exception(
        'Failed to load flights: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<List<Flight>> getFlightsByUserId(String userId) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/myflights/user/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Flight.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load flights for user');
    }
  }

  Future<Flight> getFlightById(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/myflights/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Flight.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load flight');
    }
  }

  Future<List<Flight>> searchFlights({
    String? departureAirportId,
    String? arrivalAirportId,
    DateTime? date,
  }) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final Map<String, String> queryParameters = {};

    if (departureAirportId != null) {
      queryParameters['departureAirportId'] = departureAirportId;
    }
    if (arrivalAirportId != null) {
      queryParameters['arrivalAirportId'] = arrivalAirportId;
    }
    if (date != null) {
      queryParameters['date'] = date.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse('$baseUrl/api/v1/myflights/search').replace(
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
    );

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Flight.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search flights');
    }
  }

  Future<Flight> createFlight(Map<String, dynamic> flightData) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/myflights'),
      headers: headers,
      body: jsonEncode(flightData),
    );

    if (response.statusCode == 200) {
      return Flight.fromJson(jsonDecode(response.body));
    } else {
      logDebug(
        'Failed to create flight: Status Code: ${response.statusCode}, Body: ${response.body}',
      );
      throw Exception('Failed to create flight');
    }
  }

  Future<void> updateFlight(String id, Map<String, dynamic> flightData) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/myflights/$id'),
      headers: headers,
      body: jsonEncode(flightData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update flight');
    }
  }

  Future<Map<String, dynamic>> getLatestEditedDate() async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/myflights/latestEditedDate'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get latest edited date');
    }
  }

  Future<void> deleteFlight(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/myflights/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete flight');
    }
  }
}

class LoginResponse {
  final String token;
  final DateTime expiresAt;
  final int status;

  LoginResponse({
    required this.token,
    required this.expiresAt,
    required this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt'] * 1000),
      status: json['status'],
    );
  }
}
