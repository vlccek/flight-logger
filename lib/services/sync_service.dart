import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flight_logger/services/api_service.dart';
import 'package:flight_logger/services/drift_service.dart';
import 'package:flight_logger/database/database.dart' hide RoutePoint;
import 'package:flight_logger/database/database.dart' as db;
import 'package:flight_logger/models/flight.dart' as api_flight;
import 'package:flight_logger/utils/logger.dart';
import 'package:intl/intl.dart';

class SyncService {
  final ApiService _apiService = ApiService();
  final DriftService _driftService = DriftService.instance;

  Future<void> synchronizeFlights() async {
    logDebug('Starting flight synchronization...');

    try {
      // 1. Get local and remote flights
      final localFlights = await _driftService.getAllFlights();
      final remoteFlights = await _apiService.getFlights();

      final localFlightsMap = {
        for (var f in localFlights) f.remoteID?.toString(): f,
      };
      final remoteFlightsMap = {for (var f in remoteFlights) f.id: f};

      logDebug('--- Sync Cycle Started ---');
      logDebug('Local flights count: ${localFlights.length}');
      logDebug('Remote flights count: ${remoteFlights.length}');

      // 2. Process remote flights (download changes)
      for (final remoteFlight in remoteFlights) {
        final localFlight =
            localFlightsMap[remoteFlight.id]; // Find local by remoteID

        if (localFlight == null) {
          // Case A: Remote flight exists, but not locally. Insert new local flight.
          logDebug(
            'New remote flight found: #${remoteFlight.id}. Creating locally.',
          );
          await _driftService.saveFlight(_apiFlightToDrift(remoteFlight));
        } else {
          // Case B: Flight exists in both places. Check if remote is newer.
          final remoteEditedAt =
              remoteFlight.editedAt?.millisecondsSinceEpoch ?? 0;
          final localEditedAt =
              localFlight.editedAt?.millisecondsSinceEpoch ?? 0;

          logDebug(
            'Comparing flight #${remoteFlight.id}: localEditedAt: ${localFlight.editedAt?.toIso8601String()}, remoteEditedAt: ${remoteFlight.editedAt?.toIso8601String()}',
          );

          if (remoteEditedAt > localEditedAt) {
            // Remote is newer. Update local flight with remote data.
            logDebug(
              'Remote flight #${remoteFlight.id} is newer. Updating local record.',
            );
            // Create a companion that updates all fields from remote, but keeps local ID
            final companion = _apiFlightToDrift(
              remoteFlight,
            ).copyWith(id: Value(localFlight.id));
            await _driftService.saveFlight(companion);
          }
        }
      }

      // 3. Process local flights (upload changes)
      for (final localFlight in localFlights) {
        final remoteFlight =
            remoteFlightsMap[localFlight.remoteID
                ?.toString()]; // Find remote by local's remoteID


        final localEditedAt = localFlight.editedAt?.millisecondsSinceEpoch ?? 0;
        final localSyncedAt = localFlight.syncedAt?.millisecondsSinceEpoch ?? 0;

        logDebug(
          'Processing local flight #${localFlight.id}: remoteID: ${localFlight.remoteID}, localEditedAt: ${localFlight.editedAt?.toIso8601String()}',
        );

        if (localFlight.remoteID == null) {
          // Case C: New local flight (no remoteID). Create on server.
          logDebug(
            'New local flight #${localFlight.id} found. Uploading to server.',
          );
          try {
            final apiData = await _driftFlightToApi(localFlight);
            logDebug('API data for new flight #${localFlight.id}: $apiData');
            final newRemoteFlight = await _apiService.createFlight(apiData);

            logDebug(
              'Server response for new flight #${localFlight.id}: id: ${newRemoteFlight.id}, editedAt: ${newRemoteFlight.editedAt?.toIso8601String()}',
            );

            // Update local record with remoteID and set sync times
            final companion = localFlight
                .toCompanion(true)
                .copyWith(
                  remoteID: Value(int.parse(newRemoteFlight.id)),
                  syncedAt: Value(newRemoteFlight.editedAt),
                  editedAt: Value(
                    newRemoteFlight.editedAt,
                  ), // Ensure editedAt is also updated to match remote after creation
                );
            await _driftService.saveFlight(companion);
            logDebug(
              'Local flight #${localFlight.id} updated with remote ID and sync times.',
            );
          } catch (e) {
            logDebug(
              'Failed to create flight #${localFlight.id} on server: $e',
            );
            // Optionally, mark local flight as failed to sync or retry later
          }
        } else if (remoteFlight == null) {
          // Case D: Local flight has remoteID, but no corresponding remote flight.
          // This could mean remote was deleted, or local was created but remote failed.
          // For now, assume local is the source of truth and try to create it again.
          // This might lead to duplicates if remote was deleted. A more robust solution
          // would involve a "deleted" flag or a separate deletion sync.
          logDebug(
            'Local flight #${localFlight.id} has remoteID but no remote counterpart. Attempting to re-create on server.',
          );
          try {
            final newRemoteFlight = await _apiService.createFlight(
              await _driftFlightToApi(localFlight),
            );
            logDebug(
              'Server response for re-created flight #${localFlight.id}: id: ${newRemoteFlight.id}, editedAt: ${newRemoteFlight.editedAt}',
            );
            // Update local record with the remoteID and set syncedAt to remote's editedAt
            await _driftService.saveFlight(
              localFlight
                  .toCompanion(true)
                  .copyWith(
                    remoteID: Value(int.parse(newRemoteFlight.id)),
                    syncedAt: Value(newRemoteFlight.editedAt),
                    editedAt: Value(newRemoteFlight.editedAt),
                  ),
            );
            logDebug(
              'Local flight #${localFlight.id} re-created and updated with remote ID and sync times.',
            );
          } catch (e) {
            logDebug(
              'Failed to re-create flight #${localFlight.id} on server: $e',
            );
          }
        } else {
          // Case E: Local flight exists and has a remote counterpart. Compare timestamps for updates.
          final remoteEditedAt =
              remoteFlight.editedAt?.millisecondsSinceEpoch ?? 0;

          logDebug(
            'Comparing local flight #${localFlight.id} for upload: localEditedAt: ${localFlight.editedAt?.toIso8601String()}, remoteEditedAt: ${remoteFlight.editedAt?.toIso8601String()}',
          );

          if (localEditedAt > localSyncedAt &&
              localEditedAt >= remoteEditedAt) {
            // Local is newer than its last synced state AND newer or equal to remote. Upload.
            logDebug(
              'Local flight #${localFlight.id} has been updated locally. Uploading changes.',
            );
            try {
              final apiData = await _driftFlightToApi(localFlight);
              logDebug(
                'API data for updating flight #${localFlight.id}: $apiData',
              );
              await _apiService.updateFlight(
                localFlight.remoteID.toString(),
                apiData,
              );
              // After successful upload, update local syncedAt to match localEditedAt
              await _driftService.saveFlight(
                localFlight
                    .toCompanion(true)
                    .copyWith(syncedAt: Value(localFlight.editedAt)),
              );
              logDebug(
                'Local flight #${localFlight.id} syncedAt updated after successful upload.',
              );
            } catch (e) {
              logDebug(
                'Failed to update flight #${localFlight.id} on server: $e',
              );
              // Optionally, mark local flight as failed to sync or retry later
            }
          }
        }
      }
      logDebug('--- Sync Cycle Completed ---');
    } catch (e, stackTrace) {
      logDebug('An error occurred during flight synchronization: $e');
      logDebug('Stack trace: $stackTrace');
      rethrow;
    } catch (e) {
      logDebug('Error during flight synchronization: $e');
    }
  }

  T _getEnumValue<T extends Enum>(
    List<T> values,
    String? name,
    T defaultValue,
  ) {
    if (name == null || name.isEmpty) {
      return defaultValue;
    }
    try {
      // Prepare the name from API for matching: lowercase and no spaces
      final preparedName = name.toLowerCase().replaceAll(' ', '');
      return values.firstWhere(
        (e) => e.name == preparedName,
        orElse: () => defaultValue,
      );
    } catch (e) {
      return defaultValue;
    }
  }

  FlightsCompanion _apiFlightToDrift(api_flight.Flight flight) {
    return FlightsCompanion(
      remoteID: Value(int.tryParse(flight.id)),
      departureAirportId: Value(int.parse(flight.departureAirportId)),
      arrivalAirportId: Value(int.parse(flight.arrivalAirportId)),
      flightDate: Value(flight.departureTime),
      flightDuration: Value(
        flight.arrivalTime.difference(flight.departureTime),
      ),
      distance: Value(flight.distance.toInt()),
      routePath: Value(
        flight.routePath
            .map(
              (e) =>
                  db.RoutePoint(latitude: e.latitude, longitude: e.longitude),
            )
            .toList(),
      ),
      directRoutePath: Value(
        flight.directRoutePath
            .map(
              (e) =>
                  db.RoutePoint(latitude: e.latitude, longitude: e.longitude),
            )
            .toList(),
      ),
      flightNumber: Value(flight.flightNumber),
      airplaneType: Value(flight.aircraftType),
      registration: Value(flight.airplaneRegistration),
      seat: Value(flight.seat),
      seatType: Value(
        _getEnumValue(db.SeatType.values, flight.seatType, db.SeatType.none),
      ),
      flightClass: Value(
        _getEnumValue(
          db.FlightClass.values,
          flight.flightClass,
          db.FlightClass.none,
        ),
      ),
      flightReason: Value(
        _getEnumValue(
          db.FlightReason.values,
          flight.flightReason,
          db.FlightReason.none,
        ),
      ),
      editedAt: Value(flight.editedAt),
      syncedAt: Value(
        flight.editedAt,
      ), // When pulling from remote, it's synced by definition
    );
  }

  //2025-07-19T22:02:56Z
  //2024-05-20T08:30:00Z
  Future<Map<String, dynamic>> _driftFlightToApi(Flight flight) async {
    return {
      'departure_airport_id': flight.departureAirportId,
      'arrival_airport_id': flight.arrivalAirportId,
      'flight_date': DateFormat(
        "yyyy-MM-ddTHH:mm:ss'Z'",
      ).format(flight.flightDate.toUtc()), // RESPECT THIS
      'flight_duration': flight.flightDuration.toString(),
      'distance': flight.distance,
      'route_path': jsonEncode(
        flight.routePath.map((e) => e.toJson()).toList(),
      ),
      'flight_number': flight.flightNumber,
      'airplane_type': flight.airplaneType,
      'airplane_registration': flight.registration,
      'seat': flight.seat,
      'seat_type': flight.seatType == db.SeatType.none
          ? ''
          : flight.seatType?.name,
      'flight_class': flight.flightClass == db.FlightClass.none
          ? ''
          : flight.flightClass?.name,
      'flight_reason': flight.flightReason == db.FlightReason.none
          ? ''
          : flight.flightReason?.name,
    };
  }
}
