import 'package:json_annotation/json_annotation.dart';

import 'package:consumers_api/consumers_api.dart' as api;

part 'db_data.g.dart';

@JsonSerializable()
class Info {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'article')
  final String article;

  Info({required this.id, required this.title, required this.article});

  api.Info toApi() {
    return api.Info(id: id, title: title, article: article);
  }

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}

@JsonSerializable()
class Certifications {
  @JsonKey(name: 'bcorp')
  final bool bcorp;

  @JsonKey(name: 'tco')
  final bool tco;

  Certifications({required this.bcorp, required this.tco});

  List<api.BadgeName> toBadges() {
    var badges = <api.BadgeName>[];
    if (bcorp) {
      badges.add(api.BadgeName.bcorp);
    }
    if (tco) {
      badges.add(api.BadgeName.tco);
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
