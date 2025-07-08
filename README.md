# Flight Logger

Flight Logger is a Flutter application designed to help aviation enthusiasts and pilots track and visualize their flights. This app allows users to log flight details, manage airport information, and display flight paths on an interactive map.

## Features:

*   **Flight Logging:** Record comprehensive details for each flight, including departure and arrival airports, dates, durations, and aircraft information.
*   **Airport Management:** View and manage a database of airports, including their ICAO codes, names, cities, and geographical coordinates.
*   **Interactive Map Display:** Visualize your flight routes on a map, with support for displaying both direct paths and detailed KML tracks.
*   **KML Import:** Import KML files to accurately represent complex flight paths, ensuring the route starts and ends precisely at the specified airport coordinates.
*   **Data Persistence:** All flight and airport data is stored locally using Drift (SQLite), ensuring your information is always available.

## Getting Started:

This project is a Flutter application. To get started:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/flight_logger.git
    cd flight_logger
    ```
2.  **Fetch dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```

For more detailed information on Flutter development, refer to the [official Flutter documentation](https://docs.flutter.dev/).