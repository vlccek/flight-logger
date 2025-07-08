// lib/database/connection/web.dart
import 'package:drift/wasm.dart';
import 'package:drift/drift.dart';
import 'package:flight_logger/utils/logger.dart';

// This is the modern implementation for the web using WebAssembly (WASM).
LazyDatabase connect() {
  return LazyDatabase(() async {
    // This `WasmDatabase` class is the new way to open a database on the web.
    // It will find the `sqlite3.wasm` file in your `web` folder.
    final result = await WasmDatabase.open(
      databaseName: 'db', // The name of the database file in IndexedDB
      sqlite3Uri: Uri.parse('sqlite3.wasm'), // The path to the wasm file
      driftWorkerUri: Uri.parse('drift_worker.js'), // Path for the web worker
    );

    if (result.missingFeatures.isNotEmpty) {
      print(
        'Warning: Your browser does not support all required features: '
        '${result.missingFeatures}',
      );
    }

    return result.resolvedExecutor;
  });
}
