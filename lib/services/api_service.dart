import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';
import '../models/airport.dart';
import '../models/flight.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorageService _secureStorageService = SecureStorageService();

  Future<String> _getBaseUrl() async {
    return await _secureStorageService.getApiUrl() ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<LoginResponse> login(String email, String password, {bool remember = false}) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'remember': remember,
      }),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/verify'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to verify token');
    }
  }

  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final baseUrl = await _getBaseUrl();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/register'),
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
  Future<List<Airport>> getAirports({String? search}) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final uri = Uri.parse('$baseUrl/api/v1/airports').replace(
      queryParameters: search != null ? {'search': search} : null,
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
    final response = await http.get(Uri.parse('$baseUrl/api/v1/airports/$id'), headers: headers);

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

    if (response.statusCode != 202) {
      throw Exception('Failed to update airport');
    }
  }

  Future<void> deleteAirport(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/api/v1/airports/$id'), headers: headers);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete airport');
    }
  }

  // Flight Endpoints
  Future<List<Flight>> getFlights() async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/api/v1/flights'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Flight.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load flights');
    }
  }

  Future<Flight> getFlightById(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/api/v1/flights/$id'), headers: headers);

    if (response.statusCode == 200) {
      return Flight.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load flight');
    }
  }

  Future<Flight> createFlight(Flight flight) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/flights'),
      headers: headers,
      body: jsonEncode(flight.toJson()),
    );

    if (response.statusCode == 200) {
      return Flight.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create flight');
    }
  }

  Future<void> updateFlight(String id, Flight flight) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/flights/$id'),
      headers: headers,
      body: jsonEncode(flight.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update flight');
    }
  }

  Future<void> deleteFlight(String id) async {
    final baseUrl = await _getBaseUrl();
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl/api/v1/flights/$id'), headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete flight');
    }
  }
}

class LoginResponse {
  final String token;
  final int expiresIn;
  final int expiresAt;
  final int status;
  final String? error;

  LoginResponse({
    required this.token,
    required this.expiresIn,
    required this.expiresAt,
    required this.status,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      expiresIn: json['expiresIn'],
      expiresAt: json['expiresAt'],
      status: json['status'],
      error: json['error'],
    );
  }
}
