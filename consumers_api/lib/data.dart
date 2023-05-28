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

enum ScorerName {
  // Fashion Transparency Index
  @JsonValue('fti')
  fti,
}

extension ScorerNameExtension on ScorerName {
  String get name {
    return ["fti"][index];
  }

  InfoTopic toInfoTopic() {
    switch (this) {
      case ScorerName.fti:
        return InfoTopic.fti;
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

  @JsonValue('cert--fti')
  fti,
}

extension InfoTopicExtension on InfoTopic {
  String get name {
    return ["info--main", "badge--bcorp", "badge--tco", "badge--fti"][index];
  }
}

@JsonSerializable()
class Info {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'article')
  final String article;

  Info({
    required this.id,
    required this.title,
    required this.article,
  });

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}

@JsonSerializable()
class Organisation {
  @JsonKey(name: 'organisation_id')
  final String organisationId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'badges')
  final List<BadgeName> badges;

  @JsonKey(name: 'scores')
  final Map<ScorerName, int> scores;

  Organisation({
    required this.organisationId,
    required this.name,
    required this.description,
    required this.badges,
    required this.scores,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) =>
      _$OrganisationFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationToJson(this);
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

  @JsonKey(name: 'scores')
  final Map<ScorerName, int> scores;

  ProductShort({
    required this.productId,
    required this.name,
    required this.description,
    required this.badges,
    required this.scores,
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
  final List<Organisation>? manufacturers;

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
