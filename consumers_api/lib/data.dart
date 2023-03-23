import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

enum BadgeName {
  @JsonValue('bcorp')
  bcorp,

  @JsonValue('tco')
  tco,
}

extension BadgeNameExtension on BadgeName {
  String get name {
    return ["bcorp", "tco"][index];
  }

  InfoTopic toInfoTopic() {
    switch (this) {
      case BadgeName.bcorp:
        return InfoTopic.bcorp;
      case BadgeName.tco:
        return InfoTopic.tco;
    }
  }
}

enum InfoTopic {
  @JsonValue('info--main')
  main,

  @JsonValue('cert--bcorp')
  bcorp,

  @JsonValue('cert--tco')
  tco,
}

extension InfoTopicExtension on InfoTopic {
  String get name {
    return ["info--main", "badge--bcorp", "badge--tco"][index];
  }
}

@JsonSerializable()
class Info {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'usage')
  final String? usage;

  Info({
    required this.title,
    required this.description,
    required this.usage,
  });

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}

@JsonSerializable()
class ProductShort {
  @JsonKey(name: 'product_id')
  final String productId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'badges')
  final List<BadgeName> badges;

  ProductShort({
    required this.productId,
    required this.name,
    required this.description,
    required this.badges,
  });

  factory ProductShort.fromJson(Map<String, dynamic> json) =>
      _$ProductShortFromJson(json);
  Map<String, dynamic> toJson() => _$ProductShortToJson(this);
}

@JsonSerializable()
class ProductFull {
  @JsonKey(name: 'product_id')
  final String productId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'manufacturer_ids')
  final List<String>? manufacturerIds;

  @JsonKey(name: 'manufacturers')
  final List<Manufacturer>? manufacturers;

  @JsonKey(name: 'alternatives')
  final List<ProductShort>? alternatives;

  ProductFull({
    required this.productId,
    required this.name,
    required this.description,
    required this.manufacturerIds,
    this.manufacturers,
    this.alternatives,
  });

  factory ProductFull.fromJson(Map<String, dynamic> json) =>
      _$ProductFullFromJson(json);
  Map<String, dynamic> toJson() => _$ProductFullToJson(this);
}

@JsonSerializable()
class Manufacturer {
  @JsonKey(name: 'manufacturer_id')
  final String manufacturerId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'badges')
  final List<BadgeName> badges;

  Manufacturer({
    required this.manufacturerId,
    required this.name,
    required this.description,
    required this.badges,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}
