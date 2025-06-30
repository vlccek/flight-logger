// lib/database/connection/unsupported.dart
import 'package:drift/drift.dart';

// This is a stub file for unsupported platforms.
LazyDatabase connect() {
  throw UnsupportedError('No suitable database implementation was found.');
}