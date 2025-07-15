import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'secure_storage_service.dart';

/// Enum representing the user's authentication state.
enum AuthState {
  /// The state is unknown, typically during app startup.
  unknown,

  /// The user is authenticated and the token is valid.
  authenticated,

  /// The user is not authenticated or the token has expired.
  unauthenticated,
}

/// A service to manage user authentication.
///
/// This service is the single source of truth for the user's authentication status.
/// It handles login, logout, and token persistence.
class AuthService {
  // Singleton instance
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  // final ApiService _apiService = ApiService(); // This created a circular dependency
  final SecureStorageService _secureStorageService = SecureStorageService();

  /// Notifier for the authentication state.
  ///
  /// Widgets can listen to this to react to auth changes.
  final ValueNotifier<AuthState> authStateNotifier = ValueNotifier(
    AuthState.unknown,
  );

  /// Initializes the service on app startup.
  ///
  /// Checks for a stored token, validates its expiration, and sets the
  /// initial authentication state.
  Future<void> init() async {
    final token = await _secureStorageService.getToken();
    if (token == null) {
      authStateNotifier.value = AuthState.unauthenticated;
      return;
    }

    final expiresAtStr = await _secureStorageService.getExpiresAt();
    if (expiresAtStr == null) {
      // If we have a token but no expiry, something is wrong. Log out.
      await logout();
      return;
    }

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      // Token is expired, log out.
      await logout();
    } else {
      // Token is valid.
      authStateNotifier.value = AuthState.authenticated;
    }
  }

  /// Logs the user in.
  ///
  /// On success, saves the token and updates the auth state.
  Future<bool> login(String email, String password) async {
    try {
      // Call the singleton instance directly
      final response = await ApiService().login(email, password);
      final expiresAt = response.expiresAt;

      await _secureStorageService.saveToken(response.token);
      await _secureStorageService.saveExpiresAt(expiresAt);
      await _secureStorageService.saveEmail(
        email,
      ); // For pre-filling login form

      authStateNotifier.value = AuthState.authenticated;
      return true;
    } catch (e) {
      // On failure, ensure we are fully logged out.
      await logout();
      return false;
    }
  }

  /// Logs the user out.
  ///
  /// Deletes the token from storage and updates the auth state.
  Future<void> logout() async {
    await _secureStorageService.deleteToken();
    await _secureStorageService.deleteExpiresAt();
    authStateNotifier.value = AuthState.unauthenticated;
  }

  /// Retrieves the current valid token.
  ///
  /// Returns the token if it exists and is not expired, otherwise returns null
  /// and logs the user out.
  Future<String?> getToken() async {
    final token = await _secureStorageService.getToken();
    if (token == null) {
      if (authStateNotifier.value != AuthState.unauthenticated) {
        await logout();
      }
      return null;
    }

    final expiresAtStr = await _secureStorageService.getExpiresAt();
    if (expiresAtStr == null) {
      await logout();
      return null;
    }

    final expiresAt = DateTime.tryParse(expiresAtStr);
    if (expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      await logout();
      return null;
    }

    return token;
  }
}
