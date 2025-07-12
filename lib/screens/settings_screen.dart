import 'package:flight_logger/services/api_service.dart';
import 'package:flutter/material.dart';

import 'package:flight_logger/services/secure_storage_service.dart';
import 'package:flight_logger/services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiUrlController = TextEditingController();
  final _secureStorageService = SecureStorageService();
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    _emailController.text = await _secureStorageService.getEmail() ?? '';
    _passwordController.text = await _secureStorageService.getPassword() ?? '';
    _apiUrlController.text = await _secureStorageService.getApiUrl() ?? '';
    _token = await _secureStorageService.getToken();
    setState(() {});
  }

  void _saveCredentials() async {
    if (_formKey.currentState!.validate()) {
      await _secureStorageService.saveEmail(_emailController.text);
      await _secureStorageService.savePassword(_passwordController.text);
      await _secureStorageService.saveApiUrl(_apiUrlController.text);

      ApiService().login(_emailController.text, _passwordController.text);

      // Placeholder for token generation
      const generatedToken = 'your_generated_token_placeholder';
      await _secureStorageService.saveToken(generatedToken);

      setState(() {
        _token = generatedToken;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Credentials saved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _apiUrlController,
                decoration: const InputDecoration(labelText: 'API URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the API URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCredentials,
                child: const Text('Save'),
              ),
              const SizedBox(height: 20),
              if (_token != null)
                Text(
                  'Generated Token: $_token',
                  style: const TextStyle(fontSize: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
