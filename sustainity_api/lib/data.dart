import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'data.g.dart';

enum BadgeName {
  @JsonValue('bcorp')
  bcorp,

  @JsonValue('eu')
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

enum MedallionName {
  @JsonValue('bcorp')
  bcorp,

  @JsonValue('eu')
  euEcolabel,

  @JsonValue('fti')
  fti,

  @JsonValue('sustainity')
  sustainity,

  @JsonValue('tco')
  tco,

  @JsonValue('not_found')
  notFound,
}

const medallionNames = ["bcorp", "eu", "fti", "sustainity", "tco", ""];

extension MedallionNameExtension on MedallionName {
  String get name {
    return medallionNames[index];
  }

  static MedallionName fromString(String string) {
    return MedallionName.values.firstWhere(
      (n) => n.name == string,
      orElse: () => MedallionName.notFound,
    );
  }
}

@JsonSerializable()
class Medallion with EquatableMixin {
  MedallionName name;

  Medallion(this.name);

  @override
  List<Object> get props => [name];

  factory Medallion.fromJson(Map<String, dynamic> json) {
    switch (MedallionNameExtension.fromString(json["name"])) {
      case MedallionName.bcorp:
        return BCorpMedallion.fromJson(json);
      case MedallionName.fti:
        return FtiMedallion.fromJson(json);
      case MedallionName.euEcolabel:
        return EuEcolabelMedallion.fromJson(json);
      case MedallionName.sustainity:
        return SustainityMedallion.fromJson(json);
      case MedallionName.tco:
        return TcoMedallion.fromJson(json);
      case MedallionName.notFound:
        return Medallion(MedallionName.notFound);
    }
  }
  Map<String, dynamic> toJson() => _$MedallionToJson(this);
}

@JsonSerializable()
class BCorpMedallion extends Medallion {
  @JsonKey(name: 'id')
  final String id;

  BCorpMedallion({required this.id}) : super(MedallionName.bcorp);

  @override
  List<Object> get props => [name, id];

  factory BCorpMedallion.fromJson(Map<String, dynamic> json) =>
      _$BCorpMedallionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$BCorpMedallionToJson(this);
}

@JsonSerializable()
class EuEcolabelMedallion extends Medallion {
  @JsonKey(name: 'match_accuracy')
  final double matchAccuracy;

  EuEcolabelMedallion({required this.matchAccuracy})
      : super(MedallionName.euEcolabel);

  @override
  List<Object> get props => [name, matchAccuracy];

  factory EuEcolabelMedallion.fromJson(Map<String, dynamic> json) =>
      _$EuEcolabelMedallionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$EuEcolabelMedallionToJson(this);
}

@JsonSerializable()
class FtiMedallion extends Medallion {
  @JsonKey(name: 'score')
  int score;

  FtiMedallion({required this.score}) : super(MedallionName.fti);

  @override
  List<Object> get props => [name, score];

  factory FtiMedallion.fromJson(Map<String, dynamic> json) =>
      _$FtiMedallionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FtiMedallionToJson(this);
}

@JsonSerializable()
class SustainityMedallion extends Medallion {
  @JsonKey(name: 'score')
  final SustainityScore score;

  SustainityMedallion({required this.score}) : super(MedallionName.sustainity);

  @override
  List<Object> get props => [name, score];

  factory SustainityMedallion.fromJson(Map<String, dynamic> json) =>
      _$SustainityMedallionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SustainityMedallionToJson(this);
}

@JsonSerializable()
class TcoMedallion extends Medallion {
  @JsonKey(name: 'brand_name')
  final String brandName;

  TcoMedallion({required this.brandName}) : super(MedallionName.tco);

  @override
  List<Object> get props => [name, brandName];

  factory TcoMedallion.fromJson(Map<String, dynamic> json) =>
      _$TcoMedallionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$TcoMedallionToJson(this);
}

enum LibraryTopic {
  main,
  forProducers,
  faq,
  wikidata,
  openFoodFacts,
  bcorp,
  euEcolabel,
  tco,
  fti,
  notFound,
}

const libraryTopicNames = [
  "info:main",
  "info:for_producers",
  "info:faq",
  "data:wiki",
  "data:open_food_facts",
  "cert:bcorp",
  "cert:eu_ecolabel",
  "cert:tco",
  "cert:fti",
  "other:not_found",
];

extension LibraryTopicExtension on LibraryTopic {
  String get name {
    return libraryTopicNames[index];
  }

  static LibraryTopic fromString(String string) {
    return LibraryTopic.values.firstWhere(
      (t) => t.name == string,
      orElse: () => LibraryTopic.notFound,
    );
  }
}

@JsonSerializable()
class CategoryAlternatives with EquatableMixin {
  @JsonKey(name: 'category')
  String category;

  @JsonKey(name: 'alternatives')
  List<ProductShort> alternatives;

  CategoryAlternatives({required this.category, required this.alternatives});

  @override
  List<Object> get props => [category, alternatives];

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
class Text with EquatableMixin {
  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'source')
  final Source source;

  Text({required this.text, required this.source});

  @override
  List<Object> get props => [text, source];

  factory Text.fromJson(Map<String, dynamic> json) => _$TextFromJson(json);
  Map<String, dynamic> toJson() => _$TextToJson(this);
}

@JsonSerializable()
class Image with EquatableMixin {
  @JsonKey(name: 'image')
  final String image;

  @JsonKey(name: 'source')
  final Source source;

  Image({required this.image, required this.source});

  @override
  List<Object> get props => [image, source];

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

@JsonSerializable()
class PresentationEntry {
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'score')
  int score;

  PresentationEntry({
    required this.id,
    required this.name,
    required this.score,
  });

  factory PresentationEntry.fromJson(Map<String, dynamic> json) =>
      _$PresentationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$PresentationEntryToJson(this);
}

@JsonSerializable()
class Presentation {
  @JsonKey(name: 'data')
  List<PresentationEntry> data;

  Presentation({required this.data});

  factory Presentation.fromJson(Map<String, dynamic> json) =>
      _$PresentationFromJson(json);
  Map<String, dynamic> toJson() => _$PresentationToJson(this);
}

@JsonSerializable()
class LibraryInfoShort {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'summary')
  final String summary;

  LibraryInfoShort({
    required this.id,
    required this.title,
    required this.summary,
  });

  factory LibraryInfoShort.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoShortFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryInfoShortToJson(this);
}

@JsonSerializable()
class LibraryInfoFull {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'summary')
  final String summary;

  @JsonKey(name: 'article')
  final String article;

  @JsonKey(name: 'presentation')
  final Presentation? presentation;

  LibraryInfoFull({
    required this.id,
    required this.title,
    required this.summary,
    required this.article,
    required this.presentation,
  });

  factory LibraryInfoFull.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoFullFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryInfoFullToJson(this);
}

@JsonSerializable()
class SustainityScoreBranch {
  @JsonKey(name: 'symbol')
  final String symbol;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'weight')
  final int weight;

  @JsonKey(name: 'score')
  final double score;

  @JsonKey(name: 'branches')
  final List<SustainityScoreBranch> branches;

  SustainityScoreBranch({
    required this.symbol,
    required this.description,
    required this.weight,
    required this.score,
    required this.branches,
  });

  factory SustainityScoreBranch.fromJson(Map<String, dynamic> json) =>
      _$SustainityScoreBranchFromJson(json);
  Map<String, dynamic> toJson() => _$SustainityScoreBranchToJson(this);
}

@JsonSerializable()
class SustainityScore {
  @JsonKey(name: 'tree')
  final List<SustainityScoreBranch> tree;

  @JsonKey(name: 'total')
  final double total;

  SustainityScore({required this.tree, required this.total});

  factory SustainityScore.fromJson(Map<String, dynamic> json) =>
      _$SustainityScoreFromJson(json);
  Map<String, dynamic> toJson() => _$SustainityScoreToJson(this);
}

@JsonSerializable()
class OrganisationShort with EquatableMixin {
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

  @override
  List<Object?> get props => [
        organisationId,
        name,
        description,
        badges,
        scores,
      ];

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

  @JsonKey(name: 'products')
  final List<ProductShort> products;

  @JsonKey(name: 'medallions')
  final List<Medallion> medallions;

  OrganisationFull({
    required this.organisationId,
    required this.names,
    required this.descriptions,
    required this.images,
    required this.websites,
    required this.products,
    required this.medallions,
  });

  factory OrganisationFull.fromJson(Map<String, dynamic> json) =>
      _$OrganisationFullFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationFullToJson(this);
}

@JsonSerializable()
class ProductShort with EquatableMixin {
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

  @override
  List<Object?> get props => [productId, name, description, badges, scores];

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

  @JsonKey(name: 'images')
  final List<Image> images;

  @JsonKey(name: 'manufacturers')
  final List<OrganisationShort>? manufacturers;

  @JsonKey(name: 'alternatives')
  final List<CategoryAlternatives> alternatives;

  @JsonKey(name: 'medallions')
  final List<Medallion> medallions;

  ProductFull({
    required this.productId,
    required this.gtins,
    required this.names,
    required this.descriptions,
    required this.medallions,
    required this.images,
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
