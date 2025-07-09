// lib/screens/flight_list_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/drift_service.dart';
import '../widgets/app_drawer.dart'; // Your service
import 'add_flight_screen.dart'; // Screen to add/edit flights

class FlightListScreen extends StatefulWidget {
  const FlightListScreen({super.key});

  static const routeName = '/list-flights';

  @override
  State<FlightListScreen> createState() => _FlightListScreenState();
}

class _FlightListScreenState extends State<FlightListScreen> {
  // Get the stream from our singleton service instance.
  final Stream<List<FlightWithDetails>> _flightsStream = DriftService.instance
      .watchAllFlightsWithDetails();

  // Helper for date formatting
  final DateFormat _dateFormatter = DateFormat('d. M. yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: const Text('Import Flights')),
      body: StreamBuilder<List<FlightWithDetails>>(
        stream: _flightsStream,
        builder: (context, snapshot) {
          // 1. Handle loading state
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Handle error state
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final flights = snapshot.data!;

          // 3. Handle empty state
          if (flights.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.airplanemode_inactive,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No flights recorded yet.',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // 4. Display the list of flights
          return ListView.builder(
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final item = flights[index];
              final flight = item.flight;
              final departure = item.departureAirport;
              final arrival = item.arrivalAirport;

              // Use Dismissible for swipe-to-delete functionality
              return Dismissible(
                key: ValueKey(flight.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red.shade700,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete_forever, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Call the delete method from our service
                  DriftService.instance.deleteFlight(flight.id);

                  // Show a confirmation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Flight from ${departure.city} to ${arrival.city} deleted.',
                      ),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          // Undo functionality is complex, for now we just show the button
                          // To implement it, you would save the deleted flight temporarily
                          // and re-insert it if the user clicks undo.
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.flight_takeoff),
                  ),
                  title: Text(
                    '${departure.city} (${departure.icaoCode}) → ${arrival.city} (${arrival.icaoCode})',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_dateFormatter.format(flight.flightDate)} • ${flight.flightDuration.inHours}h ${flight.flightDuration.inMinutes.remainder(60)}m • ${(flight.distance / 1000).toStringAsFixed(1)} km',
                      ),
                      if (flight.flightNumber != null && flight.flightNumber!.isNotEmpty)
                        Text('Flight: ${flight.flightNumber}'),
                      if (flight.airplaneType != null && flight.airplaneType!.isNotEmpty)
                        Text('Aircraft: ${flight.airplaneType}'),
                      if (flight.registration != null && flight.registration!.isNotEmpty)
                        Text('Reg: ${flight.registration}'),
                      if (flight.seat != null && flight.seat!.isNotEmpty)
                        Text('Seat: ${flight.seat} (${flight.seatType?.toString().split('.').last ?? 'N/A'})'),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddFlightScreen(flightToEdit: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the screen for adding a new flight
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddFlightScreen()),
          );
        },
        tooltip: 'Add New Flight',
        child: const Icon(Icons.add),
      ),
    );
  }
}