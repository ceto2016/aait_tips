import '../base_domain_imports.dart';

class CountryEntity extends BaseIdAndNameEntity {
  final String key;
  final String flag;

  const CountryEntity({
    required super.id,
    required super.name,
    required this.key,
    required this.flag,
  });
  
  @override
  CountryEntity copyWith({
    int? id,
    String? name,
    String? key,
    String? flag,
  }) =>
      CountryEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        key: key ?? this.key,
        flag: flag ?? this.flag,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "key": key,
        "flag": flag,
      };

  factory CountryEntity.fromJson(Map<String, dynamic> json) => CountryEntity(
        id: json["id"],
        name: json["name"],
        key: json["key"],
        flag: json["flag"],
      );
}

class NationalityEntity extends BaseIdAndNameEntity {
  final String locale;

  const NationalityEntity({
    required super.id,
    required super.name,
    required this.locale,
  });

  @override
  NationalityEntity copyWith({
    int? id,
    String? name,
    String? locale,
  }) =>
      NationalityEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        locale: locale ?? this.locale,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "locale": locale,
      };

  factory NationalityEntity.fromJson(Map<String, dynamic> json) =>
      NationalityEntity(
        id: json["id"],
        name: json["name"],
        locale: json["locale"],
      );
}

class CityEntity extends BaseIdAndNameEntity {
  final String region;
  final int regionId;

  const CityEntity({
    required super.id,
    required super.name,
    required this.region,
    required this.regionId,
  });

  @override
  CityEntity copyWith({
    int? id,
    String? name,
    String? region,
    int? regionId,
  }) =>
      CityEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        region: region ?? this.region,
        regionId: regionId ?? this.regionId,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "region": region,
        "region_id": regionId,
      };

  factory CityEntity.fromJson(Map<String, dynamic> json) => CityEntity(
        id: json["id"],
        name: json["name"],
    region: json["region"] ?? "",
    regionId: json["region_id"] ?? 0,
      );
}

class ActivityCloth extends BaseIdAndNameEntity {
  final String type;

  const ActivityCloth({
    required super.id,
    super.name = "",
    required this.type,
  });

  @override
  ActivityCloth copyWith({
    int? id,
    String? type,
  }) =>
      ActivityCloth(
        id: id ?? this.id,
        type: type ?? this.type,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
      };

  factory ActivityCloth.fromJson(Map<String, dynamic> json) => ActivityCloth(
        id: json["id"],
        type: json["type"],
      );
}

//activity-ages
class ActivityAge extends BaseIdAndNameEntity {
  final String type;

  const ActivityAge({
    required super.id,
    super.name = "",
    required this.type,
  });

  @override
  ActivityAge copyWith({
    int? id,
    String? type,
  }) =>
      ActivityAge(
        id: id ?? this.id,
        type: type ?? this.type,
      );

  @override
  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
      };

  factory ActivityAge.fromJson(Map<String, dynamic> json) => ActivityAge(
        id: json["id"],
        type: json["type"],
      );
}
