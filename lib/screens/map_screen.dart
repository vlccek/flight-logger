import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ByteData;
import 'package:maplibre/maplibre.dart';
import 'package:geodesy/geodesy.dart';

import 'dart:typed_data';
import 'package:flutter/services.dart';

import '../models/routes.dart';
import '../services/route_service.dart';
import '../widgets/app_drawer.dart';




@immutable
class LayersPolylinePage extends StatefulWidget {
  const LayersPolylinePage({super.key});

  static const routeName = '/';

  @override
  State<LayersPolylinePage> createState() => _LayersPolylinePageState();
}

class _LayersPolylinePageState extends State<LayersPolylinePage> {
  MapController? _mapController;
  final RouteService _routeService = RouteService();

  // Loading state management.
  bool _isLoading = true;
  String? _errorMessage;

  // Route data.
  List<VisuRouteModel> _userRoutes = [];
  List<LineString> _routePolylines = [];

  // GeoJSON source for airport markers.
  List<Point> _airportPoints = [];

  bool _pinImageLoaded = false;

  // The unique ID we will give our pin image once loaded.
  static const String pinImageId = 'pin';

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  // Loads route data and generates map geometries.
  Future<void> _loadRoutes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final routes = await _routeService.loadUserRoutes();
      setState(() {
        _userRoutes = routes;
        _isLoading = false;
      });

      _generateGeometries();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading routes: $e';
      });
    }
  }

  void _generateGeometries() {
    // The final list of polylines to be displayed.
    final List<LineString> polylines = [];
    // The final list of airport markers to be displayed.
    final List<Point> airportPoints = [];

    // Sets to track uniqueness to prevent duplicate geometries.
    final Set<String> uniqueRouteKeys = {};
    final Set<String> uniqueAirportCoords = {};

    // Loop through all user-provided routes.
    for (final route in _userRoutes) {
      final startCoords = '${route.start.longitude},${route.start.latitude}';
      final endCoords = '${route.end.longitude},${route.end.latitude}';

      // --- Handle Airport Markers ---
      // Inspired by the provided example, we create a list of `Point` objects.

      // Add the starting airport to the list if it has not been added before.
      if (uniqueAirportCoords.add(startCoords)) {
        airportPoints.add(
          Point(
            coordinates: Position(route.start.longitude, route.start.latitude),
          ),
        );
      }

      // Add the ending airport to the list if it has not been added before.
      if (uniqueAirportCoords.add(endCoords)) {
        airportPoints.add(
          Point(coordinates: Position(route.end.longitude, route.end.latitude)),
        );
      }

      // --- Handle Unique Route Polylines ---

      // Create a direction-agnostic key for the route by sorting the coordinates.
      // This ensures that "Prague -> New York" is treated the same as "New York -> Prague".
      final routeKey = ([startCoords, endCoords]..sort()).join(' -> ');

      // Only generate the polyline if this route has not been processed yet.
      if (uniqueRouteKeys.add(routeKey)) {
        final pointCount = _routeService.calculatePointsForRoute(route);
        final positions = _routeService.generateRoutePositions(
          route.start,
          route.end,
          pointCount,
        );
        polylines.add(LineString(coordinates: positions));
      }
    }

    // Update the component's state with the newly generated geometries.
    // Note: The state variables `_routePolylines` and `_airportPoints` must
    // exist in your StatefulWidget's state class.
    setState(() {
      _routePolylines = polylines;
      _airportPoints =
          airportPoints; // This will hold your list of airport markers.
    });
  }

  // Builds the summary widget with travel statistics.
  Widget _buildSummary() {
    final totalDistance = _userRoutes.fold(
      0.0,
      (sum, route) => sum + (route.distance ?? 0),
    );
    final numberOfFlights = _userRoutes.length;
    final uniqueAirports = _airportPoints.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
            '${(totalDistance / 1000).toStringAsFixed(0)} km',
            'Total Distance',
          ),
          _buildStatColumn('$numberOfFlights', 'Flights'),
          _buildStatColumn('$uniqueAirports', 'Airports Visited'),
        ],
      ),
    );
  }

  // Helper method to build a single statistic column.
  Widget _buildStatColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Routes'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRoutes),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[100],
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!)),
                  TextButton(
                    onPressed: _loadRoutes,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  _buildSummary(),
                  Expanded(
                    child: MapLibreMap(
                      options: MapOptions(
                        initZoom: 2,
                        initCenter: Position(15.0, 49.5),
                      ),
                      onMapCreated: (controller) {
                        setState(() => _mapController = controller);
                      },
                      onStyleLoaded: (style) {
                        style.setProjection(MapProjection.globe);

                        // Add the source and layer for airport markers.
                      },
                      onEvent: (event) async {
                        switch (event) {
                          case MapEventStyleLoaded():
                            final ByteData byteData = await rootBundle.load(
                              'images/pin.png',
                            );
                            final Uint8List bytes = byteData.buffer
                                .asUint8List();

                            // 2. Add the image data to the map's style with our unique ID.
                            await event.style.addImage(pinImageId, bytes);
                            _pinImageLoaded = true;
                          default:
                            // ignore all other events
                            break;
                        }
                      },
                      layers: [
                        // Layer for the flight path polylines.
                        PolylineLayer(
                          polylines: _routePolylines,
                          color: Colors.red,
                          width: 2,
                        ),
                        MarkerLayer(
                          points: _airportPoints,
                          textAllowOverlap: true,
                          iconImage: pinImageId,
                          iconSize: 0.3,
                          iconAllowOverlap: true,
                          iconAnchor: IconAnchor.bottom,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
