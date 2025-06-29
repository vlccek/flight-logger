// lib/screens/add_flight_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
// Import your models and data here

class AddFlightScreen extends StatefulWidget {
  const AddFlightScreen({super.key});

  static const routeName = '/add-flight'; // Doporučuji pomlčky pro čitelnost

  @override
  State<AddFlightScreen> createState() => _AddFlightScreenState();
}

class _AddFlightScreenState extends State<AddFlightScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _airports = [
    'Prague (PRG)',
    'New York (JFK)',
    'London (LHR)',
    'Tokyo (HND)',
  ];
  String? _selectedDeparture;
  String? _selectedArrival;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, process the data.
      // Here you would call your FlightService to save the flight.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Flight from $_selectedDeparture to $_selectedArrival saved!',
          ),
        ),
      );
      // Potentially clear the form or navigate away.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a New Flight')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _selectedDeparture,
                hint: const Text('Select Departure Airport'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDeparture = newValue;
                  });
                },
                items: _airports.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a departure airport' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedArrival,
                hint: const Text('Select Arrival Airport'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedArrival = newValue;
                  });
                },
                items: _airports.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select an arrival airport' : null,
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Flight'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
