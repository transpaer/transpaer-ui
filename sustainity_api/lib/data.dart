import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

enum BadgeName {
  @JsonValue('bcorp')
  bcorp,

  @JsonValue('eu_ecolabel')
  euEcolabel,

  @JsonValue('tco')
  tco,
}

extension BadgeNameExtension on BadgeName {
  String get name {
    return ["bcorp", "euEcolabel", "tco"][index];
  }

  LibraryTopic toLibraryTopic() {
    switch (this) {
      case BadgeName.bcorp:
        return LibraryTopic.bcorp;
      case BadgeName.euEcolabel:
        return LibraryTopic.euEcolabel;
      case BadgeName.tco:
        return LibraryTopic.tco;
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

  LibraryTopic toLibraryTopic() {
    switch (this) {
      case ScorerName.fti:
        return LibraryTopic.fti;
    }
  }
}

enum LibraryTopic {
  main,
  forProducers,
  bcorp,
  euEcolabel,
  tco,
  fti,
}

extension LibraryTopicExtension on LibraryTopic {
  String get name {
    return [
      "info:main",
      "info:for_producers",
      "cert:bcorp",
      "cert:eu_ecolabel",
      "cert:tco",
      "cert:fti"
    ][index];
  }

  static LibraryTopic fromString(String string) {
    return LibraryTopic.values
        .firstWhere((t) => t.name == string, orElse: () => LibraryTopic.main);
  }
}

@JsonSerializable()
class CategoryAlternatives {
  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'alternatives')
  List<ProductShort> alternatives;

  CategoryAlternatives({required this.category, required this.alternatives});

  factory CategoryAlternatives.fromJson(Map<String, dynamic> json) =>
      _$CategoryAlternativesFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryAlternativesToJson(this);
}

enum Source {
  @JsonValue('wiki')
  wikidata,

  @JsonValue('off')
  openFoodFacts,

  @JsonValue('eu')
  euEcolabel,
}

@JsonSerializable()
class Text {
  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'source')
  final Source source;

  Text({required this.text, required this.source});

  @override
  bool operator ==(Object other) {
    return (other is Text) && (other.text == text) && (other.source == source);
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + text.hashCode;
    result = 37 * result + source.hashCode;
    return result;
  }

  factory Text.fromJson(Map<String, dynamic> json) => _$TextFromJson(json);
  Map<String, dynamic> toJson() => _$TextToJson(this);
}

@JsonSerializable()
class Image {
  @JsonKey(name: 'image')
  final String image;

  @JsonKey(name: 'source')
  final Source source;

  Image({required this.image, required this.source});

  @override
  bool operator ==(Object other) {
    return (other is Image) &&
        (other.image == image) &&
        (other.source == source);
  }

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + image.hashCode;
    result = 37 * result + source.hashCode;
    return result;
  }

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

@JsonSerializable()
class LibraryInfo {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'article')
  final String article;

  LibraryInfo({
    required this.id,
    required this.title,
    required this.article,
  });

  factory LibraryInfo.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryInfoToJson(this);
}

@JsonSerializable()
class OrganisationShort {
  @JsonKey(name: 'organisation_id')
  final String organisationId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'badges')
  final List<BadgeName> badges;

  @JsonKey(name: 'scores')
  final Map<ScorerName, int> scores;

  OrganisationShort({
    required this.organisationId,
    required this.name,
    required this.description,
    required this.badges,
    required this.scores,
  });

  factory OrganisationShort.fromJson(Map<String, dynamic> json) =>
      _$OrganisationShortFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationShortToJson(this);
}

@JsonSerializable()
class OrganisationFull {
  @JsonKey(name: 'organisation_id')
  final String organisationId;

  @JsonKey(name: 'names')
  final List<Text> names;

  @JsonKey(name: 'descriptions')
  final List<Text> descriptions;

  @JsonKey(name: 'images')
  final List<Image> images;

  @JsonKey(name: 'websites')
  final List<String> websites;

  @JsonKey(name: 'badges')
  final List<BadgeName> badges;

  @JsonKey(name: 'scores')
  final Map<ScorerName, int> scores;

  OrganisationFull({
    required this.organisationId,
    required this.names,
    required this.descriptions,
    required this.images,
    required this.websites,
    required this.badges,
    required this.scores,
  });

  factory OrganisationFull.fromJson(Map<String, dynamic> json) =>
      _$OrganisationFullFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationFullToJson(this);
}

@JsonSerializable()
class ProductShort {
  @JsonKey(name: 'product_id')
  final String productId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

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

  @JsonKey(name: 'gtins')
  final List<String> gtins;

  @JsonKey(name: 'names')
  final List<Text> names;

  @JsonKey(name: 'descriptions')
  final List<Text> descriptions;

  @JsonKey(name: 'badges')
  final List<BadgeName> badges;

  @JsonKey(name: 'scores')
  final Map<ScorerName, int> scores;

  @JsonKey(name: 'images')
  final List<Image> images;

  @JsonKey(name: 'manufacturer_ids')
  final List<String>? manufacturerIds;

  @JsonKey(name: 'manufacturers')
  final List<OrganisationShort>? manufacturers;

  @JsonKey(name: 'alternatives')
  final List<CategoryAlternatives> alternatives;

  ProductFull({
    required this.productId,
    required this.gtins,
    required this.names,
    required this.descriptions,
    required this.badges,
    required this.scores,
    required this.images,
    required this.manufacturerIds,
    required this.manufacturers,
    required this.alternatives,
  });

  factory ProductFull.fromJson(Map<String, dynamic> json) =>
      _$ProductFullFromJson(json);
  Map<String, dynamic> toJson() => _$ProductFullToJson(this);
}

enum SearchResultVariant {
  @JsonValue('product')
  product,

  @JsonValue('organisation')
  organisation,
}

@JsonSerializable()
class SearchResult {
  @JsonKey(name: 'variant')
  final SearchResultVariant variant;

  @JsonKey(name: 'label')
  final String label;

  @JsonKey(name: 'id')
  final String id;

  SearchResult({required this.variant, required this.label, required this.id});

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}
