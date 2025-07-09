import 'package:logging/logging.dart';

final logger = Logger('FlightLogger');

void setupLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

void logDebug(String message) {
  logger.fine(message);
}
