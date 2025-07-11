// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AirportsTable extends Airports with TableInfo<$AirportsTable, Airport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AirportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _icaoCodeMeta = const VerificationMeta(
    'icaoCode',
  );
  @override
  late final GeneratedColumn<String> icaoCode = GeneratedColumn<String>(
    'icao_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 4,
      maxTextLength: 4,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    icaoCode,
    name,
    city,
    country,
    latitude,
    longitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'airports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Airport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('icao_code')) {
      context.handle(
        _icaoCodeMeta,
        icaoCode.isAcceptableOrUnknown(data['icao_code']!, _icaoCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_icaoCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Airport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Airport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      icaoCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icao_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
    );
  }

  @override
  $AirportsTable createAlias(String alias) {
    return $AirportsTable(attachedDatabase, alias);
  }
}

class Airport extends DataClass implements Insertable<Airport> {
  final int id;
  final String icaoCode;
  final String name;
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  const Airport({
    required this.id,
    required this.icaoCode,
    required this.name,
    required this.city,
    required this.country,
    required this.latitude,
    required this.longitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['icao_code'] = Variable<String>(icaoCode);
    map['name'] = Variable<String>(name);
    map['city'] = Variable<String>(city);
    map['country'] = Variable<String>(country);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    return map;
  }

  AirportsCompanion toCompanion(bool nullToAbsent) {
    return AirportsCompanion(
      id: Value(id),
      icaoCode: Value(icaoCode),
      name: Value(name),
      city: Value(city),
      country: Value(country),
      latitude: Value(latitude),
      longitude: Value(longitude),
    );
  }

  factory Airport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Airport(
      id: serializer.fromJson<int>(json['id']),
      icaoCode: serializer.fromJson<String>(json['icaoCode']),
      name: serializer.fromJson<String>(json['name']),
      city: serializer.fromJson<String>(json['city']),
      country: serializer.fromJson<String>(json['country']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'icaoCode': serializer.toJson<String>(icaoCode),
      'name': serializer.toJson<String>(name),
      'city': serializer.toJson<String>(city),
      'country': serializer.toJson<String>(country),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
    };
  }

  Airport copyWith({
    int? id,
    String? icaoCode,
    String? name,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
  }) => Airport(
    id: id ?? this.id,
    icaoCode: icaoCode ?? this.icaoCode,
    name: name ?? this.name,
    city: city ?? this.city,
    country: country ?? this.country,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );
  Airport copyWithCompanion(AirportsCompanion data) {
    return Airport(
      id: data.id.present ? data.id.value : this.id,
      icaoCode: data.icaoCode.present ? data.icaoCode.value : this.icaoCode,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
      country: data.country.present ? data.country.value : this.country,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Airport(')
          ..write('id: $id, ')
          ..write('icaoCode: $icaoCode, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, icaoCode, name, city, country, latitude, longitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Airport &&
          other.id == this.id &&
          other.icaoCode == this.icaoCode &&
          other.name == this.name &&
          other.city == this.city &&
          other.country == this.country &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class AirportsCompanion extends UpdateCompanion<Airport> {
  final Value<int> id;
  final Value<String> icaoCode;
  final Value<String> name;
  final Value<String> city;
  final Value<String> country;
  final Value<double> latitude;
  final Value<double> longitude;
  const AirportsCompanion({
    this.id = const Value.absent(),
    this.icaoCode = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
  });
  AirportsCompanion.insert({
    this.id = const Value.absent(),
    required String icaoCode,
    required String name,
    required String city,
    required String country,
    required double latitude,
    required double longitude,
  }) : icaoCode = Value(icaoCode),
       name = Value(name),
       city = Value(city),
       country = Value(country),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<Airport> custom({
    Expression<int>? id,
    Expression<String>? icaoCode,
    Expression<String>? name,
    Expression<String>? city,
    Expression<String>? country,
    Expression<double>? latitude,
    Expression<double>? longitude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (icaoCode != null) 'icao_code': icaoCode,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
  }

  AirportsCompanion copyWith({
    Value<int>? id,
    Value<String>? icaoCode,
    Value<String>? name,
    Value<String>? city,
    Value<String>? country,
    Value<double>? latitude,
    Value<double>? longitude,
  }) {
    return AirportsCompanion(
      id: id ?? this.id,
      icaoCode: icaoCode ?? this.icaoCode,
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (icaoCode.present) {
      map['icao_code'] = Variable<String>(icaoCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AirportsCompanion(')
          ..write('id: $id, ')
          ..write('icaoCode: $icaoCode, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }
}

class $FlightsTable extends Flights with TableInfo<$FlightsTable, Flight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _departureAirportIdMeta =
      const VerificationMeta('departureAirportId');
  @override
  late final GeneratedColumn<int> departureAirportId = GeneratedColumn<int>(
    'departure_airport_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES airports (id)',
    ),
  );
  static const VerificationMeta _arrivalAirportIdMeta = const VerificationMeta(
    'arrivalAirportId',
  );
  @override
  late final GeneratedColumn<int> arrivalAirportId = GeneratedColumn<int>(
    'arrival_airport_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES airports (id)',
    ),
  );
  static const VerificationMeta _flightDateMeta = const VerificationMeta(
    'flightDate',
  );
  @override
  late final GeneratedColumn<DateTime> flightDate = GeneratedColumn<DateTime>(
    'flight_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Duration, int> flightDuration =
      GeneratedColumn<int>(
        'flight_duration',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Duration>($FlightsTable.$converterflightDuration);
  static const VerificationMeta _distanceMeta = const VerificationMeta(
    'distance',
  );
  @override
  late final GeneratedColumn<int> distance = GeneratedColumn<int>(
    'distance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<RoutePoint>, String>
  routePath = GeneratedColumn<String>(
    'route_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<RoutePoint>>($FlightsTable.$converterroutePath);
  @override
  late final GeneratedColumnWithTypeConverter<List<RoutePoint>, String>
  directRoutePath = GeneratedColumn<String>(
    'direct_route_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<RoutePoint>>($FlightsTable.$converterdirectRoutePath);
  static const VerificationMeta _flightNumberMeta = const VerificationMeta(
    'flightNumber',
  );
  @override
  late final GeneratedColumn<String> flightNumber = GeneratedColumn<String>(
    'flight_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airplaneTypeMeta = const VerificationMeta(
    'airplaneType',
  );
  @override
  late final GeneratedColumn<String> airplaneType = GeneratedColumn<String>(
    'airplane_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registrationMeta = const VerificationMeta(
    'registration',
  );
  @override
  late final GeneratedColumn<String> registration = GeneratedColumn<String>(
    'registration',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<String> seat = GeneratedColumn<String>(
    'seat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SeatType?, int> seatType =
      GeneratedColumn<int>(
        'seat_type',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<SeatType?>($FlightsTable.$converterseatTypen);
  static const VerificationMeta _flightClassMeta = const VerificationMeta(
    'flightClass',
  );
  @override
  late final GeneratedColumn<String> flightClass = GeneratedColumn<String>(
    'flight_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _flightReasonMeta = const VerificationMeta(
    'flightReason',
  );
  @override
  late final GeneratedColumn<String> flightReason = GeneratedColumn<String>(
    'flight_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    departureAirportId,
    arrivalAirportId,
    flightDate,
    flightDuration,
    distance,
    routePath,
    directRoutePath,
    flightNumber,
    airplaneType,
    registration,
    seat,
    seatType,
    flightClass,
    flightReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flights';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flight> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('departure_airport_id')) {
      context.handle(
        _departureAirportIdMeta,
        departureAirportId.isAcceptableOrUnknown(
          data['departure_airport_id']!,
          _departureAirportIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureAirportIdMeta);
    }
    if (data.containsKey('arrival_airport_id')) {
      context.handle(
        _arrivalAirportIdMeta,
        arrivalAirportId.isAcceptableOrUnknown(
          data['arrival_airport_id']!,
          _arrivalAirportIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalAirportIdMeta);
    }
    if (data.containsKey('flight_date')) {
      context.handle(
        _flightDateMeta,
        flightDate.isAcceptableOrUnknown(data['flight_date']!, _flightDateMeta),
      );
    } else if (isInserting) {
      context.missing(_flightDateMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(
        _distanceMeta,
        distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta),
      );
    } else if (isInserting) {
      context.missing(_distanceMeta);
    }
    if (data.containsKey('flight_number')) {
      context.handle(
        _flightNumberMeta,
        flightNumber.isAcceptableOrUnknown(
          data['flight_number']!,
          _flightNumberMeta,
        ),
      );
    }
    if (data.containsKey('airplane_type')) {
      context.handle(
        _airplaneTypeMeta,
        airplaneType.isAcceptableOrUnknown(
          data['airplane_type']!,
          _airplaneTypeMeta,
        ),
      );
    }
    if (data.containsKey('registration')) {
      context.handle(
        _registrationMeta,
        registration.isAcceptableOrUnknown(
          data['registration']!,
          _registrationMeta,
        ),
      );
    }
    if (data.containsKey('seat')) {
      context.handle(
        _seatMeta,
        seat.isAcceptableOrUnknown(data['seat']!, _seatMeta),
      );
    }
    if (data.containsKey('flight_class')) {
      context.handle(
        _flightClassMeta,
        flightClass.isAcceptableOrUnknown(
          data['flight_class']!,
          _flightClassMeta,
        ),
      );
    }
    if (data.containsKey('flight_reason')) {
      context.handle(
        _flightReasonMeta,
        flightReason.isAcceptableOrUnknown(
          data['flight_reason']!,
          _flightReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flight(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      departureAirportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}departure_airport_id'],
      )!,
      arrivalAirportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arrival_airport_id'],
      )!,
      flightDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}flight_date'],
      )!,
      flightDuration: $FlightsTable.$converterflightDuration.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}flight_duration'],
        )!,
      ),
      distance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance'],
      )!,
      routePath: $FlightsTable.$converterroutePath.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}route_path'],
        )!,
      ),
      directRoutePath: $FlightsTable.$converterdirectRoutePath.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direct_route_path'],
        )!,
      ),
      flightNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flight_number'],
      ),
      airplaneType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}airplane_type'],
      ),
      registration: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registration'],
      ),
      seat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seat'],
      ),
      seatType: $FlightsTable.$converterseatTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}seat_type'],
        ),
      ),
      flightClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flight_class'],
      ),
      flightReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flight_reason'],
      ),
    );
  }

  @override
  $FlightsTable createAlias(String alias) {
    return $FlightsTable(attachedDatabase, alias);
  }

  static TypeConverter<Duration, int> $converterflightDuration =
      const DurationConverter();
  static TypeConverter<List<RoutePoint>, String> $converterroutePath =
      const RoutePathConverter();
  static TypeConverter<List<RoutePoint>, String> $converterdirectRoutePath =
      const RoutePathConverter();
  static TypeConverter<SeatType, int> $converterseatType =
      const SeatTypeConverter();
  static TypeConverter<SeatType?, int?> $converterseatTypen =
      NullAwareTypeConverter.wrap($converterseatType);
}

class Flight extends DataClass implements Insertable<Flight> {
  final int id;
  final int departureAirportId;
  final int arrivalAirportId;
  final DateTime flightDate;
  final Duration flightDuration;
  final int distance;
  final List<RoutePoint> routePath;
  final List<RoutePoint> directRoutePath;
  final String? flightNumber;
  final String? airplaneType;
  final String? registration;
  final String? seat;
  final SeatType? seatType;
  final String? flightClass;
  final String? flightReason;
  const Flight({
    required this.id,
    required this.departureAirportId,
    required this.arrivalAirportId,
    required this.flightDate,
    required this.flightDuration,
    required this.distance,
    required this.routePath,
    required this.directRoutePath,
    this.flightNumber,
    this.airplaneType,
    this.registration,
    this.seat,
    this.seatType,
    this.flightClass,
    this.flightReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['departure_airport_id'] = Variable<int>(departureAirportId);
    map['arrival_airport_id'] = Variable<int>(arrivalAirportId);
    map['flight_date'] = Variable<DateTime>(flightDate);
    {
      map['flight_duration'] = Variable<int>(
        $FlightsTable.$converterflightDuration.toSql(flightDuration),
      );
    }
    map['distance'] = Variable<int>(distance);
    {
      map['route_path'] = Variable<String>(
        $FlightsTable.$converterroutePath.toSql(routePath),
      );
    }
    {
      map['direct_route_path'] = Variable<String>(
        $FlightsTable.$converterdirectRoutePath.toSql(directRoutePath),
      );
    }
    if (!nullToAbsent || flightNumber != null) {
      map['flight_number'] = Variable<String>(flightNumber);
    }
    if (!nullToAbsent || airplaneType != null) {
      map['airplane_type'] = Variable<String>(airplaneType);
    }
    if (!nullToAbsent || registration != null) {
      map['registration'] = Variable<String>(registration);
    }
    if (!nullToAbsent || seat != null) {
      map['seat'] = Variable<String>(seat);
    }
    if (!nullToAbsent || seatType != null) {
      map['seat_type'] = Variable<int>(
        $FlightsTable.$converterseatTypen.toSql(seatType),
      );
    }
    if (!nullToAbsent || flightClass != null) {
      map['flight_class'] = Variable<String>(flightClass);
    }
    if (!nullToAbsent || flightReason != null) {
      map['flight_reason'] = Variable<String>(flightReason);
    }
    return map;
  }

  FlightsCompanion toCompanion(bool nullToAbsent) {
    return FlightsCompanion(
      id: Value(id),
      departureAirportId: Value(departureAirportId),
      arrivalAirportId: Value(arrivalAirportId),
      flightDate: Value(flightDate),
      flightDuration: Value(flightDuration),
      distance: Value(distance),
      routePath: Value(routePath),
      directRoutePath: Value(directRoutePath),
      flightNumber: flightNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(flightNumber),
      airplaneType: airplaneType == null && nullToAbsent
          ? const Value.absent()
          : Value(airplaneType),
      registration: registration == null && nullToAbsent
          ? const Value.absent()
          : Value(registration),
      seat: seat == null && nullToAbsent ? const Value.absent() : Value(seat),
      seatType: seatType == null && nullToAbsent
          ? const Value.absent()
          : Value(seatType),
      flightClass: flightClass == null && nullToAbsent
          ? const Value.absent()
          : Value(flightClass),
      flightReason: flightReason == null && nullToAbsent
          ? const Value.absent()
          : Value(flightReason),
    );
  }

  factory Flight.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flight(
      id: serializer.fromJson<int>(json['id']),
      departureAirportId: serializer.fromJson<int>(json['departureAirportId']),
      arrivalAirportId: serializer.fromJson<int>(json['arrivalAirportId']),
      flightDate: serializer.fromJson<DateTime>(json['flightDate']),
      flightDuration: serializer.fromJson<Duration>(json['flightDuration']),
      distance: serializer.fromJson<int>(json['distance']),
      routePath: serializer.fromJson<List<RoutePoint>>(json['routePath']),
      directRoutePath: serializer.fromJson<List<RoutePoint>>(
        json['directRoutePath'],
      ),
      flightNumber: serializer.fromJson<String?>(json['flightNumber']),
      airplaneType: serializer.fromJson<String?>(json['airplaneType']),
      registration: serializer.fromJson<String?>(json['registration']),
      seat: serializer.fromJson<String?>(json['seat']),
      seatType: serializer.fromJson<SeatType?>(json['seatType']),
      flightClass: serializer.fromJson<String?>(json['flightClass']),
      flightReason: serializer.fromJson<String?>(json['flightReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'departureAirportId': serializer.toJson<int>(departureAirportId),
      'arrivalAirportId': serializer.toJson<int>(arrivalAirportId),
      'flightDate': serializer.toJson<DateTime>(flightDate),
      'flightDuration': serializer.toJson<Duration>(flightDuration),
      'distance': serializer.toJson<int>(distance),
      'routePath': serializer.toJson<List<RoutePoint>>(routePath),
      'directRoutePath': serializer.toJson<List<RoutePoint>>(directRoutePath),
      'flightNumber': serializer.toJson<String?>(flightNumber),
      'airplaneType': serializer.toJson<String?>(airplaneType),
      'registration': serializer.toJson<String?>(registration),
      'seat': serializer.toJson<String?>(seat),
      'seatType': serializer.toJson<SeatType?>(seatType),
      'flightClass': serializer.toJson<String?>(flightClass),
      'flightReason': serializer.toJson<String?>(flightReason),
    };
  }

  Flight copyWith({
    int? id,
    int? departureAirportId,
    int? arrivalAirportId,
    DateTime? flightDate,
    Duration? flightDuration,
    int? distance,
    List<RoutePoint>? routePath,
    List<RoutePoint>? directRoutePath,
    Value<String?> flightNumber = const Value.absent(),
    Value<String?> airplaneType = const Value.absent(),
    Value<String?> registration = const Value.absent(),
    Value<String?> seat = const Value.absent(),
    Value<SeatType?> seatType = const Value.absent(),
    Value<String?> flightClass = const Value.absent(),
    Value<String?> flightReason = const Value.absent(),
  }) => Flight(
    id: id ?? this.id,
    departureAirportId: departureAirportId ?? this.departureAirportId,
    arrivalAirportId: arrivalAirportId ?? this.arrivalAirportId,
    flightDate: flightDate ?? this.flightDate,
    flightDuration: flightDuration ?? this.flightDuration,
    distance: distance ?? this.distance,
    routePath: routePath ?? this.routePath,
    directRoutePath: directRoutePath ?? this.directRoutePath,
    flightNumber: flightNumber.present ? flightNumber.value : this.flightNumber,
    airplaneType: airplaneType.present ? airplaneType.value : this.airplaneType,
    registration: registration.present ? registration.value : this.registration,
    seat: seat.present ? seat.value : this.seat,
    seatType: seatType.present ? seatType.value : this.seatType,
    flightClass: flightClass.present ? flightClass.value : this.flightClass,
    flightReason: flightReason.present ? flightReason.value : this.flightReason,
  );
  Flight copyWithCompanion(FlightsCompanion data) {
    return Flight(
      id: data.id.present ? data.id.value : this.id,
      departureAirportId: data.departureAirportId.present
          ? data.departureAirportId.value
          : this.departureAirportId,
      arrivalAirportId: data.arrivalAirportId.present
          ? data.arrivalAirportId.value
          : this.arrivalAirportId,
      flightDate: data.flightDate.present
          ? data.flightDate.value
          : this.flightDate,
      flightDuration: data.flightDuration.present
          ? data.flightDuration.value
          : this.flightDuration,
      distance: data.distance.present ? data.distance.value : this.distance,
      routePath: data.routePath.present ? data.routePath.value : this.routePath,
      directRoutePath: data.directRoutePath.present
          ? data.directRoutePath.value
          : this.directRoutePath,
      flightNumber: data.flightNumber.present
          ? data.flightNumber.value
          : this.flightNumber,
      airplaneType: data.airplaneType.present
          ? data.airplaneType.value
          : this.airplaneType,
      registration: data.registration.present
          ? data.registration.value
          : this.registration,
      seat: data.seat.present ? data.seat.value : this.seat,
      seatType: data.seatType.present ? data.seatType.value : this.seatType,
      flightClass: data.flightClass.present
          ? data.flightClass.value
          : this.flightClass,
      flightReason: data.flightReason.present
          ? data.flightReason.value
          : this.flightReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flight(')
          ..write('id: $id, ')
          ..write('departureAirportId: $departureAirportId, ')
          ..write('arrivalAirportId: $arrivalAirportId, ')
          ..write('flightDate: $flightDate, ')
          ..write('flightDuration: $flightDuration, ')
          ..write('distance: $distance, ')
          ..write('routePath: $routePath, ')
          ..write('directRoutePath: $directRoutePath, ')
          ..write('flightNumber: $flightNumber, ')
          ..write('airplaneType: $airplaneType, ')
          ..write('registration: $registration, ')
          ..write('seat: $seat, ')
          ..write('seatType: $seatType, ')
          ..write('flightClass: $flightClass, ')
          ..write('flightReason: $flightReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    departureAirportId,
    arrivalAirportId,
    flightDate,
    flightDuration,
    distance,
    routePath,
    directRoutePath,
    flightNumber,
    airplaneType,
    registration,
    seat,
    seatType,
    flightClass,
    flightReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flight &&
          other.id == this.id &&
          other.departureAirportId == this.departureAirportId &&
          other.arrivalAirportId == this.arrivalAirportId &&
          other.flightDate == this.flightDate &&
          other.flightDuration == this.flightDuration &&
          other.distance == this.distance &&
          other.routePath == this.routePath &&
          other.directRoutePath == this.directRoutePath &&
          other.flightNumber == this.flightNumber &&
          other.airplaneType == this.airplaneType &&
          other.registration == this.registration &&
          other.seat == this.seat &&
          other.seatType == this.seatType &&
          other.flightClass == this.flightClass &&
          other.flightReason == this.flightReason);
}

class FlightsCompanion extends UpdateCompanion<Flight> {
  final Value<int> id;
  final Value<int> departureAirportId;
  final Value<int> arrivalAirportId;
  final Value<DateTime> flightDate;
  final Value<Duration> flightDuration;
  final Value<int> distance;
  final Value<List<RoutePoint>> routePath;
  final Value<List<RoutePoint>> directRoutePath;
  final Value<String?> flightNumber;
  final Value<String?> airplaneType;
  final Value<String?> registration;
  final Value<String?> seat;
  final Value<SeatType?> seatType;
  final Value<String?> flightClass;
  final Value<String?> flightReason;
  const FlightsCompanion({
    this.id = const Value.absent(),
    this.departureAirportId = const Value.absent(),
    this.arrivalAirportId = const Value.absent(),
    this.flightDate = const Value.absent(),
    this.flightDuration = const Value.absent(),
    this.distance = const Value.absent(),
    this.routePath = const Value.absent(),
    this.directRoutePath = const Value.absent(),
    this.flightNumber = const Value.absent(),
    this.airplaneType = const Value.absent(),
    this.registration = const Value.absent(),
    this.seat = const Value.absent(),
    this.seatType = const Value.absent(),
    this.flightClass = const Value.absent(),
    this.flightReason = const Value.absent(),
  });
  FlightsCompanion.insert({
    this.id = const Value.absent(),
    required int departureAirportId,
    required int arrivalAirportId,
    required DateTime flightDate,
    required Duration flightDuration,
    required int distance,
    required List<RoutePoint> routePath,
    required List<RoutePoint> directRoutePath,
    this.flightNumber = const Value.absent(),
    this.airplaneType = const Value.absent(),
    this.registration = const Value.absent(),
    this.seat = const Value.absent(),
    this.seatType = const Value.absent(),
    this.flightClass = const Value.absent(),
    this.flightReason = const Value.absent(),
  }) : departureAirportId = Value(departureAirportId),
       arrivalAirportId = Value(arrivalAirportId),
       flightDate = Value(flightDate),
       flightDuration = Value(flightDuration),
       distance = Value(distance),
       routePath = Value(routePath),
       directRoutePath = Value(directRoutePath);
  static Insertable<Flight> custom({
    Expression<int>? id,
    Expression<int>? departureAirportId,
    Expression<int>? arrivalAirportId,
    Expression<DateTime>? flightDate,
    Expression<int>? flightDuration,
    Expression<int>? distance,
    Expression<String>? routePath,
    Expression<String>? directRoutePath,
    Expression<String>? flightNumber,
    Expression<String>? airplaneType,
    Expression<String>? registration,
    Expression<String>? seat,
    Expression<int>? seatType,
    Expression<String>? flightClass,
    Expression<String>? flightReason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (departureAirportId != null)
        'departure_airport_id': departureAirportId,
      if (arrivalAirportId != null) 'arrival_airport_id': arrivalAirportId,
      if (flightDate != null) 'flight_date': flightDate,
      if (flightDuration != null) 'flight_duration': flightDuration,
      if (distance != null) 'distance': distance,
      if (routePath != null) 'route_path': routePath,
      if (directRoutePath != null) 'direct_route_path': directRoutePath,
      if (flightNumber != null) 'flight_number': flightNumber,
      if (airplaneType != null) 'airplane_type': airplaneType,
      if (registration != null) 'registration': registration,
      if (seat != null) 'seat': seat,
      if (seatType != null) 'seat_type': seatType,
      if (flightClass != null) 'flight_class': flightClass,
      if (flightReason != null) 'flight_reason': flightReason,
    });
  }

  FlightsCompanion copyWith({
    Value<int>? id,
    Value<int>? departureAirportId,
    Value<int>? arrivalAirportId,
    Value<DateTime>? flightDate,
    Value<Duration>? flightDuration,
    Value<int>? distance,
    Value<List<RoutePoint>>? routePath,
    Value<List<RoutePoint>>? directRoutePath,
    Value<String?>? flightNumber,
    Value<String?>? airplaneType,
    Value<String?>? registration,
    Value<String?>? seat,
    Value<SeatType?>? seatType,
    Value<String?>? flightClass,
    Value<String?>? flightReason,
  }) {
    return FlightsCompanion(
      id: id ?? this.id,
      departureAirportId: departureAirportId ?? this.departureAirportId,
      arrivalAirportId: arrivalAirportId ?? this.arrivalAirportId,
      flightDate: flightDate ?? this.flightDate,
      flightDuration: flightDuration ?? this.flightDuration,
      distance: distance ?? this.distance,
      routePath: routePath ?? this.routePath,
      directRoutePath: directRoutePath ?? this.directRoutePath,
      flightNumber: flightNumber ?? this.flightNumber,
      airplaneType: airplaneType ?? this.airplaneType,
      registration: registration ?? this.registration,
      seat: seat ?? this.seat,
      seatType: seatType ?? this.seatType,
      flightClass: flightClass ?? this.flightClass,
      flightReason: flightReason ?? this.flightReason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (departureAirportId.present) {
      map['departure_airport_id'] = Variable<int>(departureAirportId.value);
    }
    if (arrivalAirportId.present) {
      map['arrival_airport_id'] = Variable<int>(arrivalAirportId.value);
    }
    if (flightDate.present) {
      map['flight_date'] = Variable<DateTime>(flightDate.value);
    }
    if (flightDuration.present) {
      map['flight_duration'] = Variable<int>(
        $FlightsTable.$converterflightDuration.toSql(flightDuration.value),
      );
    }
    if (distance.present) {
      map['distance'] = Variable<int>(distance.value);
    }
    if (routePath.present) {
      map['route_path'] = Variable<String>(
        $FlightsTable.$converterroutePath.toSql(routePath.value),
      );
    }
    if (directRoutePath.present) {
      map['direct_route_path'] = Variable<String>(
        $FlightsTable.$converterdirectRoutePath.toSql(directRoutePath.value),
      );
    }
    if (flightNumber.present) {
      map['flight_number'] = Variable<String>(flightNumber.value);
    }
    if (airplaneType.present) {
      map['airplane_type'] = Variable<String>(airplaneType.value);
    }
    if (registration.present) {
      map['registration'] = Variable<String>(registration.value);
    }
    if (seat.present) {
      map['seat'] = Variable<String>(seat.value);
    }
    if (seatType.present) {
      map['seat_type'] = Variable<int>(
        $FlightsTable.$converterseatTypen.toSql(seatType.value),
      );
    }
    if (flightClass.present) {
      map['flight_class'] = Variable<String>(flightClass.value);
    }
    if (flightReason.present) {
      map['flight_reason'] = Variable<String>(flightReason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlightsCompanion(')
          ..write('id: $id, ')
          ..write('departureAirportId: $departureAirportId, ')
          ..write('arrivalAirportId: $arrivalAirportId, ')
          ..write('flightDate: $flightDate, ')
          ..write('flightDuration: $flightDuration, ')
          ..write('distance: $distance, ')
          ..write('routePath: $routePath, ')
          ..write('directRoutePath: $directRoutePath, ')
          ..write('flightNumber: $flightNumber, ')
          ..write('airplaneType: $airplaneType, ')
          ..write('registration: $registration, ')
          ..write('seat: $seat, ')
          ..write('seatType: $seatType, ')
          ..write('flightClass: $flightClass, ')
          ..write('flightReason: $flightReason')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AirportsTable airports = $AirportsTable(this);
  late final $FlightsTable flights = $FlightsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [airports, flights];
}

typedef $$AirportsTableCreateCompanionBuilder =
    AirportsCompanion Function({
      Value<int> id,
      required String icaoCode,
      required String name,
      required String city,
      required String country,
      required double latitude,
      required double longitude,
    });
typedef $$AirportsTableUpdateCompanionBuilder =
    AirportsCompanion Function({
      Value<int> id,
      Value<String> icaoCode,
      Value<String> name,
      Value<String> city,
      Value<String> country,
      Value<double> latitude,
      Value<double> longitude,
    });

final class $$AirportsTableReferences
    extends BaseReferences<_$AppDatabase, $AirportsTable, Airport> {
  $$AirportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlightsTable, List<Flight>>
  _departingFlightsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.flights,
    aliasName: $_aliasNameGenerator(
      db.airports.id,
      db.flights.departureAirportId,
    ),
  );

  $$FlightsTableProcessedTableManager get departingFlights {
    final manager = $$FlightsTableTableManager($_db, $_db.flights).filter(
      (f) => f.departureAirportId.id.sqlEquals($_itemColumn<int>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_departingFlightsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FlightsTable, List<Flight>> _arrivingFlightsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.flights,
    aliasName: $_aliasNameGenerator(
      db.airports.id,
      db.flights.arrivalAirportId,
    ),
  );

  $$FlightsTableProcessedTableManager get arrivingFlights {
    final manager = $$FlightsTableTableManager(
      $_db,
      $_db.flights,
    ).filter((f) => f.arrivalAirportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_arrivingFlightsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AirportsTableFilterComposer
    extends Composer<_$AppDatabase, $AirportsTable> {
  $$AirportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icaoCode => $composableBuilder(
    column: $table.icaoCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> departingFlights(
    Expression<bool> Function($$FlightsTableFilterComposer f) f,
  ) {
    final $$FlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.departureAirportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableFilterComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> arrivingFlights(
    Expression<bool> Function($$FlightsTableFilterComposer f) f,
  ) {
    final $$FlightsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.arrivalAirportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableFilterComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AirportsTableOrderingComposer
    extends Composer<_$AppDatabase, $AirportsTable> {
  $$AirportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icaoCode => $composableBuilder(
    column: $table.icaoCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AirportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AirportsTable> {
  $$AirportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get icaoCode =>
      $composableBuilder(column: $table.icaoCode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  Expression<T> departingFlights<T extends Object>(
    Expression<T> Function($$FlightsTableAnnotationComposer a) f,
  ) {
    final $$FlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.departureAirportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> arrivingFlights<T extends Object>(
    Expression<T> Function($$FlightsTableAnnotationComposer a) f,
  ) {
    final $$FlightsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flights,
      getReferencedColumn: (t) => t.arrivalAirportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FlightsTableAnnotationComposer(
            $db: $db,
            $table: $db.flights,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AirportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AirportsTable,
          Airport,
          $$AirportsTableFilterComposer,
          $$AirportsTableOrderingComposer,
          $$AirportsTableAnnotationComposer,
          $$AirportsTableCreateCompanionBuilder,
          $$AirportsTableUpdateCompanionBuilder,
          (Airport, $$AirportsTableReferences),
          Airport,
          PrefetchHooks Function({bool departingFlights, bool arrivingFlights})
        > {
  $$AirportsTableTableManager(_$AppDatabase db, $AirportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AirportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AirportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AirportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> icaoCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
              }) => AirportsCompanion(
                id: id,
                icaoCode: icaoCode,
                name: name,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String icaoCode,
                required String name,
                required String city,
                required String country,
                required double latitude,
                required double longitude,
              }) => AirportsCompanion.insert(
                id: id,
                icaoCode: icaoCode,
                name: name,
                city: city,
                country: country,
                latitude: latitude,
                longitude: longitude,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AirportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({departingFlights = false, arrivingFlights = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (departingFlights) db.flights,
                    if (arrivingFlights) db.flights,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (departingFlights)
                        await $_getPrefetchedData<
                          Airport,
                          $AirportsTable,
                          Flight
                        >(
                          currentTable: table,
                          referencedTable: $$AirportsTableReferences
                              ._departingFlightsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AirportsTableReferences(
                                db,
                                table,
                                p0,
                              ).departingFlights,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.departureAirportId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (arrivingFlights)
                        await $_getPrefetchedData<
                          Airport,
                          $AirportsTable,
                          Flight
                        >(
                          currentTable: table,
                          referencedTable: $$AirportsTableReferences
                              ._arrivingFlightsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AirportsTableReferences(
                                db,
                                table,
                                p0,
                              ).arrivingFlights,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.arrivalAirportId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AirportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AirportsTable,
      Airport,
      $$AirportsTableFilterComposer,
      $$AirportsTableOrderingComposer,
      $$AirportsTableAnnotationComposer,
      $$AirportsTableCreateCompanionBuilder,
      $$AirportsTableUpdateCompanionBuilder,
      (Airport, $$AirportsTableReferences),
      Airport,
      PrefetchHooks Function({bool departingFlights, bool arrivingFlights})
    >;
typedef $$FlightsTableCreateCompanionBuilder =
    FlightsCompanion Function({
      Value<int> id,
      required int departureAirportId,
      required int arrivalAirportId,
      required DateTime flightDate,
      required Duration flightDuration,
      required int distance,
      required List<RoutePoint> routePath,
      required List<RoutePoint> directRoutePath,
      Value<String?> flightNumber,
      Value<String?> airplaneType,
      Value<String?> registration,
      Value<String?> seat,
      Value<SeatType?> seatType,
      Value<String?> flightClass,
      Value<String?> flightReason,
    });
typedef $$FlightsTableUpdateCompanionBuilder =
    FlightsCompanion Function({
      Value<int> id,
      Value<int> departureAirportId,
      Value<int> arrivalAirportId,
      Value<DateTime> flightDate,
      Value<Duration> flightDuration,
      Value<int> distance,
      Value<List<RoutePoint>> routePath,
      Value<List<RoutePoint>> directRoutePath,
      Value<String?> flightNumber,
      Value<String?> airplaneType,
      Value<String?> registration,
      Value<String?> seat,
      Value<SeatType?> seatType,
      Value<String?> flightClass,
      Value<String?> flightReason,
    });

final class $$FlightsTableReferences
    extends BaseReferences<_$AppDatabase, $FlightsTable, Flight> {
  $$FlightsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AirportsTable _departureAirportIdTable(_$AppDatabase db) =>
      db.airports.createAlias(
        $_aliasNameGenerator(db.flights.departureAirportId, db.airports.id),
      );

  $$AirportsTableProcessedTableManager get departureAirportId {
    final $_column = $_itemColumn<int>('departure_airport_id')!;

    final manager = $$AirportsTableTableManager(
      $_db,
      $_db.airports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_departureAirportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AirportsTable _arrivalAirportIdTable(_$AppDatabase db) =>
      db.airports.createAlias(
        $_aliasNameGenerator(db.flights.arrivalAirportId, db.airports.id),
      );

  $$AirportsTableProcessedTableManager get arrivalAirportId {
    final $_column = $_itemColumn<int>('arrival_airport_id')!;

    final manager = $$AirportsTableTableManager(
      $_db,
      $_db.airports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_arrivalAirportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FlightsTableFilterComposer
    extends Composer<_$AppDatabase, $FlightsTable> {
  $$FlightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get flightDate => $composableBuilder(
    column: $table.flightDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Duration, Duration, int> get flightDuration =>
      $composableBuilder(
        column: $table.flightDuration,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<RoutePoint>, List<RoutePoint>, String>
  get routePath => $composableBuilder(
    column: $table.routePath,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<RoutePoint>, List<RoutePoint>, String>
  get directRoutePath => $composableBuilder(
    column: $table.directRoutePath,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get flightNumber => $composableBuilder(
    column: $table.flightNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get airplaneType => $composableBuilder(
    column: $table.airplaneType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SeatType?, SeatType, int> get seatType =>
      $composableBuilder(
        column: $table.seatType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get flightClass => $composableBuilder(
    column: $table.flightClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flightReason => $composableBuilder(
    column: $table.flightReason,
    builder: (column) => ColumnFilters(column),
  );

  $$AirportsTableFilterComposer get departureAirportId {
    final $$AirportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableFilterComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableFilterComposer get arrivalAirportId {
    final $$AirportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableFilterComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlightsTable> {
  $$FlightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get flightDate => $composableBuilder(
    column: $table.flightDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flightDuration => $composableBuilder(
    column: $table.flightDuration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distance => $composableBuilder(
    column: $table.distance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routePath => $composableBuilder(
    column: $table.routePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directRoutePath => $composableBuilder(
    column: $table.directRoutePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flightNumber => $composableBuilder(
    column: $table.flightNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get airplaneType => $composableBuilder(
    column: $table.airplaneType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seatType => $composableBuilder(
    column: $table.seatType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flightClass => $composableBuilder(
    column: $table.flightClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flightReason => $composableBuilder(
    column: $table.flightReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$AirportsTableOrderingComposer get departureAirportId {
    final $$AirportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableOrderingComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableOrderingComposer get arrivalAirportId {
    final $$AirportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableOrderingComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlightsTable> {
  $$FlightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get flightDate => $composableBuilder(
    column: $table.flightDate,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Duration, int> get flightDuration =>
      $composableBuilder(
        column: $table.flightDuration,
        builder: (column) => column,
      );

  GeneratedColumn<int> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<RoutePoint>, String> get routePath =>
      $composableBuilder(column: $table.routePath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<RoutePoint>, String>
  get directRoutePath => $composableBuilder(
    column: $table.directRoutePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flightNumber => $composableBuilder(
    column: $table.flightNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get airplaneType => $composableBuilder(
    column: $table.airplaneType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get registration => $composableBuilder(
    column: $table.registration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SeatType?, int> get seatType =>
      $composableBuilder(column: $table.seatType, builder: (column) => column);

  GeneratedColumn<String> get flightClass => $composableBuilder(
    column: $table.flightClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flightReason => $composableBuilder(
    column: $table.flightReason,
    builder: (column) => column,
  );

  $$AirportsTableAnnotationComposer get departureAirportId {
    final $$AirportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.departureAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableAnnotationComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AirportsTableAnnotationComposer get arrivalAirportId {
    final $$AirportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.arrivalAirportId,
      referencedTable: $db.airports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AirportsTableAnnotationComposer(
            $db: $db,
            $table: $db.airports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FlightsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlightsTable,
          Flight,
          $$FlightsTableFilterComposer,
          $$FlightsTableOrderingComposer,
          $$FlightsTableAnnotationComposer,
          $$FlightsTableCreateCompanionBuilder,
          $$FlightsTableUpdateCompanionBuilder,
          (Flight, $$FlightsTableReferences),
          Flight,
          PrefetchHooks Function({
            bool departureAirportId,
            bool arrivalAirportId,
          })
        > {
  $$FlightsTableTableManager(_$AppDatabase db, $FlightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> departureAirportId = const Value.absent(),
                Value<int> arrivalAirportId = const Value.absent(),
                Value<DateTime> flightDate = const Value.absent(),
                Value<Duration> flightDuration = const Value.absent(),
                Value<int> distance = const Value.absent(),
                Value<List<RoutePoint>> routePath = const Value.absent(),
                Value<List<RoutePoint>> directRoutePath = const Value.absent(),
                Value<String?> flightNumber = const Value.absent(),
                Value<String?> airplaneType = const Value.absent(),
                Value<String?> registration = const Value.absent(),
                Value<String?> seat = const Value.absent(),
                Value<SeatType?> seatType = const Value.absent(),
                Value<String?> flightClass = const Value.absent(),
                Value<String?> flightReason = const Value.absent(),
              }) => FlightsCompanion(
                id: id,
                departureAirportId: departureAirportId,
                arrivalAirportId: arrivalAirportId,
                flightDate: flightDate,
                flightDuration: flightDuration,
                distance: distance,
                routePath: routePath,
                directRoutePath: directRoutePath,
                flightNumber: flightNumber,
                airplaneType: airplaneType,
                registration: registration,
                seat: seat,
                seatType: seatType,
                flightClass: flightClass,
                flightReason: flightReason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int departureAirportId,
                required int arrivalAirportId,
                required DateTime flightDate,
                required Duration flightDuration,
                required int distance,
                required List<RoutePoint> routePath,
                required List<RoutePoint> directRoutePath,
                Value<String?> flightNumber = const Value.absent(),
                Value<String?> airplaneType = const Value.absent(),
                Value<String?> registration = const Value.absent(),
                Value<String?> seat = const Value.absent(),
                Value<SeatType?> seatType = const Value.absent(),
                Value<String?> flightClass = const Value.absent(),
                Value<String?> flightReason = const Value.absent(),
              }) => FlightsCompanion.insert(
                id: id,
                departureAirportId: departureAirportId,
                arrivalAirportId: arrivalAirportId,
                flightDate: flightDate,
                flightDuration: flightDuration,
                distance: distance,
                routePath: routePath,
                directRoutePath: directRoutePath,
                flightNumber: flightNumber,
                airplaneType: airplaneType,
                registration: registration,
                seat: seat,
                seatType: seatType,
                flightClass: flightClass,
                flightReason: flightReason,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FlightsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({departureAirportId = false, arrivalAirportId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (departureAirportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.departureAirportId,
                                    referencedTable: $$FlightsTableReferences
                                        ._departureAirportIdTable(db),
                                    referencedColumn: $$FlightsTableReferences
                                        ._departureAirportIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (arrivalAirportId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.arrivalAirportId,
                                    referencedTable: $$FlightsTableReferences
                                        ._arrivalAirportIdTable(db),
                                    referencedColumn: $$FlightsTableReferences
                                        ._arrivalAirportIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$FlightsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlightsTable,
      Flight,
      $$FlightsTableFilterComposer,
      $$FlightsTableOrderingComposer,
      $$FlightsTableAnnotationComposer,
      $$FlightsTableCreateCompanionBuilder,
      $$FlightsTableUpdateCompanionBuilder,
      (Flight, $$FlightsTableReferences),
      Flight,
      PrefetchHooks Function({bool departureAirportId, bool arrivalAirportId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AirportsTableTableManager get airports =>
      $$AirportsTableTableManager(_db, _db.airports);
  $$FlightsTableTableManager get flights =>
      $$FlightsTableTableManager(_db, _db.flights);
}
