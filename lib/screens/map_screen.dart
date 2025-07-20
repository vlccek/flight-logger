import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre/maplibre.dart';
import 'package:flutter/foundation.dart'; // Import for defaultTargetPlatform
import '../services/drift_service.dart'; // Import your services
import '../utils/logger.dart';
import '../widgets/app_drawer.dart'; // Your AppDrawer

// Assuming your DriftService is a singleton accessible via DriftService.instance
// If not, you'll need to pass it in.

@immutable
class LayersPolylinePage extends StatefulWidget {
  const LayersPolylinePage({super.key});

  @override
  State<LayersPolylinePage> createState() => _LayersPolylinePageState();
}

class _LayersPolylinePageState extends State<LayersPolylinePage> {
  // We will get the data from the stream provided by DriftService.
  final Stream<List<FlightWithDetails>> _flightsStream = DriftService.instance
      .watchAllFlightsWithDetails();

  // The unique ID we will give our pin image once loaded.
  static const String pinImageId = 'pin';
  bool _pinImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Routes')),
      drawer: AppDrawer(),
      body: StreamBuilder<List<FlightWithDetails>>(
        stream: _flightsStream,
        builder: (context, snapshot) {
          // Handle loading state
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading flights: ${snapshot.error}'),
            );
          }

          final flights = snapshot.data!;

          // If there are no flights, show a message.
          if (flights.isEmpty) {
            return const Center(child: Text('No flights in the database.'));
          }

          // --- Data is ready, build the map ---

          // Create a list of polylines from the flight data.
          final List<PolylineLayer> polylineLayers = flights.map((
            flightDetails,
          ) {
            final bool useKmlPath = flightDetails.flight.routePath.length > 2;
            final List<Position> positions = (useKmlPath
                    ? flightDetails.flight.routePath
                    : flightDetails.flight.directRoutePath)
                .map(
                  (rp) => Position(rp.longitude, rp.latitude),
                )
                .toList();


            return PolylineLayer(
              polylines: [LineString(coordinates: positions)],
              color: Colors.red,
              width: 2,
            );
          }).toList();

          // Create a list of markers for the airports.
          final List<Point> airportPoints = [];
          final Set<int> addedAirportIds = {}; // To avoid duplicate markers
          for (var flightDetails in flights) {
            if (addedAirportIds.add(flightDetails.departureAirport.id)) {
              airportPoints.add(
                Point(
                  coordinates: Position(
                    flightDetails.departureAirport.longitude,
                    flightDetails.departureAirport.latitude,
                  ),
                ),
              );
            }
            if (addedAirportIds.add(flightDetails.arrivalAirport.id)) {
              airportPoints.add(
                Point(
                  coordinates: Position(
                    flightDetails.arrivalAirport.longitude,
                    flightDetails.arrivalAirport.latitude,
                  ),
                ),
              );
            }
          }

         return MapLibreMap(
            options: MapOptions(
              initZoom: 2,
              initCenter: Position(15.0, 49.5), // Initial center
            ),
            onStyleLoaded: (style) {
              style.setProjection(MapProjection.globe);
            },
            onEvent: (event) async {
              switch (event) {
                case MapEventStyleLoaded():
                  if (!_pinImageLoaded) {
                    final ByteData byteData = await rootBundle.load(
                      'assets/images/pin.png', // Use full path here
                    );
                    final Uint8List bytes = byteData.buffer.asUint8List();

                    // 2. Add the image data to the map's style with our unique ID.
                    await event.style.addImage(pinImageId, bytes);
                    _pinImageLoaded = true;
                  }
                default:
                  // ignore all other events
                  break;
              }
            },
            layers: [
              // Add all the flight polyline layers
              ...polylineLayers,

              // Add the marker layer for airports
              MarkerLayer(
                points: airportPoints,
                textAllowOverlap: true,
                iconImage: pinImageId,
                iconSize: defaultTargetPlatform == TargetPlatform.android ? 0.9 : 0.3,
                iconAllowOverlap: true,
                iconAnchor: IconAnchor.bottom,
              ),
            ],
          );
        },
      ),
    );
  }
}
