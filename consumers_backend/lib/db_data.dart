import 'package:json_annotation/json_annotation.dart';

import 'package:consumers_api/consumers_api.dart' as api;

part 'db_data.g.dart';

@JsonSerializable()
class Certifications {
  @JsonKey(name: 'bcorp')
  final bool bcorp;

  Certifications({required this.bcorp});

  List<String> toBadges() {
    var badges = <String>[];
    if (bcorp) {
      badges.add(api.BADGE_BCORP);
    }
    return badges;
  }

  factory Certifications.fromJson(Map<String, dynamic> json) =>
      _$CertificationsFromJson(json);
  Map<String, dynamic> toJson() => _$CertificationsToJson(this);
}

@JsonSerializable()
class Product {
  @JsonKey(name: 'id')
  final String productId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'manufacturer_ids')
  final List<String>? manufacturerIds;

  @JsonKey(name: 'follows')
  final List<String>? follows;

  @JsonKey(name: 'followed_by')
  final List<String>? followedBy;

  @JsonKey(name: 'certifications')
  final Certifications certifications;

  Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.manufacturerIds,
    required this.follows,
    required this.followedBy,
    required this.certifications,
  });

  api.ProductShort toApiShort() {
    return api.ProductShort(
      productId: productId,
      name: name,
      description: description,
      badges: certifications.toBadges(),
    );
  }

  api.ProductFull toApiFull({
    List<api.Manufacturer>? manufacturers,
    List<api.ProductShort>? alternatives,
  }) {
    return api.ProductFull(
      productId: productId,
      name: name,
      description: description,
      manufacturerIds: manufacturerIds,
      manufacturers: manufacturers,
      alternatives: alternatives,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Manufacturer {
  @JsonKey(name: 'id')
  final String manufacturerId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'certifications')
  final Certifications certifications;

  Manufacturer({
    required this.manufacturerId,
    required this.name,
    required this.description,
    required this.certifications,
  });

  api.Manufacturer toApi() {
    return api.Manufacturer(
      manufacturerId: manufacturerId,
      name: name,
      description: description,
      badges: certifications.toBadges(),
    );
  }

  factory Manufacturer.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}
