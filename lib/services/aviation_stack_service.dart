// lib/services/aviation_stack_service.dart

import 'dart:convert';
import 'package:flight_logger/utils/logger.dart';
import 'package:http/http.dart' as http;
import '../models/flight_api_response.dart'; // Import your new models

class AviationStackService {
  static const String _baseUrl = 'http://api.aviationstack.com/v1';
  final String _apiKey;

  // The API key is passed in the constructor.
  AviationStackService({required String apiKey}) : _apiKey = apiKey;

  /// Fetches flight details for a given flight number and date.
  ///
  /// The flight number should be the IATA code (e.g., 'W65094').
  /// Throws an exception if the flight is not found or if a network error occurs.
  Future<ApiFlightData> fetchFlightDetails({
    required String flightNumber,
    required DateTime date,
  }) async {
    // Format the date to YYYY-MM-DD as required by the API.
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final uri = Uri.parse(
      '$_baseUrl/flights?access_key=$_apiKey&flight_iata=$flightNumber&flight_date=$formattedDate',
    );

    logDebug('Fetching flight data from: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // The API returns a 'data' array. We need to check if it's empty.
      final List<dynamic> data = jsonResponse['data'] as List<dynamic>;

      if (data.isEmpty) {
        throw Exception('Flight not found for the specified number and date.');
      }

      // Usually, the first result is the correct one.
      return ApiFlightData.fromJson(data.first as Map<String, dynamic>);
    } else {
      // Handle API errors (e.g., invalid key, rate limit exceeded).
      final Map<String, dynamic> errorResponse = json.decode(response.body);
      final String errorMessage =
          errorResponse['error']?['message'] ?? 'Unknown API error';
      throw Exception('Failed to load flight data: $errorMessage');
    }
  }
}
