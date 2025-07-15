import 'package:flight_logger/services/auth_service.dart';
import 'package:flight_logger/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

import 'package:flight_logger/services/secure_storage_service.dart';

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

  // Use the AuthService for authentication logic
  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorageService = SecureStorageService();

  bool _isApiUrlSet = false;
  bool _isEmailSet = false;
  bool _isPasswordSet = false;
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    final email = await _secureStorageService.getEmail();
    final password = await _secureStorageService.getPassword();
    final apiUrl = await _secureStorageService.getApiUrl();

    setState(() {
      _emailController.text = email ?? '';
      _passwordController.text = password ?? '';
      _apiUrlController.text = apiUrl ?? '';

      _isEmailSet = email != null && email.isNotEmpty;
      _isPasswordSet = password != null && password.isNotEmpty;
      _isApiUrlSet = apiUrl != null && apiUrl.isNotEmpty;
    });
  }

  void _saveAndTestConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    // First, save the URL so the ApiService can use it.
    await _secureStorageService.saveApiUrl(_apiUrlController.text);
    await _secureStorageService.saveEmail(_emailController.text);
    await _secureStorageService.savePassword(_passwordController.text);

    // Now, attempt to log in using the AuthService.
    final success = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isConnecting = false;
      _isApiUrlSet = _apiUrlController.text.isNotEmpty;
      _isEmailSet = _emailController.text.isNotEmpty;
      _isPasswordSet = _passwordController.text.isNotEmpty;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Settings Saved & Connection Successful'
                : 'Failed to connect. Check credentials and URL.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Connection Status Box ---
              ValueListenableBuilder<AuthState>(
                valueListenable: _authService.authStateNotifier,
                builder: (context, authState, child) {
                  final bool isAuthenticated =
                      authState == AuthState.authenticated;
                  final bool isConfigured =
                      _isApiUrlSet && _isEmailSet && _isPasswordSet;
                  final bool isReady = isAuthenticated || isConfigured;

                  return Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: isReady
                          ? Colors.green.shade100
                          : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isReady ? Colors.green : Colors.amber,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isReady ? Icons.check_circle : Icons.warning,
                          color: isReady ? Colors.green : Colors.amber.shade800,
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Text(
                            isAuthenticated
                                ? 'You are already logged in'
                                : (isConfigured
                                      ? 'Ready to Connect'
                                      : 'Configuration Needed'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isReady
                                  ? Colors.green.shade800
                                  : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // --- Form Fields ---
              TextFormField(
                controller: _apiUrlController,
                decoration: InputDecoration(
                  labelText: 'API URL',
                  suffixIcon: _isApiUrlSet
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the API URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  suffixIcon: _isEmailSet
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: _isPasswordSet
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                ),
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
                onPressed: _isConnecting ? null : _saveAndTestConnection,
                child: _isConnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Text('Save & Test Connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
