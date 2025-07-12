class Airport {
  final String id;
  final String ident;
  final String type;
  final String name;
  final double latitudeDeg;
  final double longitudeDeg;
  final int elevationFt;
  final String continent;
  final String isoCountry;
  final String isoRegion;
  final String municipality;
  final String? scheduledService;
  final String gpsCode;
  final String iataCode;
  final String localCode;
  final String? homeLink;
  final String? wikipediaLink;
  final String? keywords;

  Airport({
    required this.id,
    required this.ident,
    required this.type,
    required this.name,
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.elevationFt,
    required this.continent,
    required this.isoCountry,
    required this.isoRegion,
    required this.municipality,
    this.scheduledService,
    required this.gpsCode,
    required this.iataCode,
    required this.localCode,
    this.homeLink,
    this.wikipediaLink,
    this.keywords,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      id: json['id'].toString(),
      ident: json['ident'],
      type: json['type'],
      name: json['name'],
      latitudeDeg: json['latitude_deg'].toDouble(),
      longitudeDeg: json['longitude_deg'].toDouble(),
      elevationFt: json['elevation_ft'],
      continent: json['continent'],
      isoCountry: json['iso_country'],
      isoRegion: json['iso_region'],
      municipality: json['municipality'],
      scheduledService: json['scheduled_service'],
      gpsCode: json['gps_code'],
      iataCode: json['iata_code'],
      localCode: json['local_code'],
      homeLink: json['home_link'],
      wikipediaLink: json['wikipedia_link'],
      keywords: json['keywords'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ident': ident,
      'type': type,
      'name': name,
      'latitude_deg': latitudeDeg,
      'longitude_deg': longitudeDeg,
      'elevation_ft': elevationFt,
      'continent': continent,
      'iso_country': isoCountry,
      'iso_region': isoRegion,
      'municipality': municipality,
      'scheduled_service': scheduledService,
      'gps_code': gpsCode,
      'iata_code': iataCode,
      'local_code': localCode,
      'home_link': homeLink,
      'wikipedia_link': wikipediaLink,
      'keywords': keywords,
    };
  }
}
