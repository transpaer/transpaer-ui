import 'package:json_annotation/json_annotation.dart';

import 'package:sustainity_api/sustainity_api.dart' as api;

part 'db_data.g.dart';

enum Source {
  @JsonValue('wiki')
  wikidata,

  @JsonValue('off')
  openFoodFacts,

  @JsonValue('eu')
  euEcolabel,
}

extension SourceExtension on Source {
  api.Source toApi() {
    switch (this) {
      case Source.wikidata:
        return api.Source.wikidata;
      case Source.openFoodFacts:
        return api.Source.openFoodFacts;
      case Source.euEcolabel:
        return api.Source.euEcolabel;
    }
  }
}

@JsonSerializable()
class Text {
  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'source')
  final Source source;

  Text({required this.text, required this.source});

  api.Text toApi() {
    return api.Text(text: text, source: source.toApi());
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

  api.Image toApi() {
    return api.Image(image: image, source: source.toApi());
  }

  factory Image.fromJson(Map<String, dynamic> json) => _$ImageFromJson(json);
  Map<String, dynamic> toJson() => _$ImageToJson(this);
}

@JsonSerializable()
class PresentationEntry {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'score')
  final int score;

  PresentationEntry({
    required this.id,
    required this.name,
    required this.score,
  });

  api.PresentationEntry toApi() {
    return api.PresentationEntry(id: id, name: name, score: score);
  }

  factory PresentationEntry.fromJson(Map<String, dynamic> json) =>
      _$PresentationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$PresentationEntryToJson(this);
}

@JsonSerializable()
class Presentation {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'data')
  final List<PresentationEntry> data;

  Presentation({required this.id, required this.data});

  api.Presentation toApi() {
    return api.Presentation(data: data.map((e) => e.toApi()).toList());
  }

  factory Presentation.fromJson(Map<String, dynamic> json) =>
      _$PresentationFromJson(json);
  Map<String, dynamic> toJson() => _$PresentationToJson(this);
}

@JsonSerializable()
class LibraryInfo {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'summary')
  final String summary;

  @JsonKey(name: 'article')
  final String article;

  LibraryInfo({
    required this.id,
    required this.title,
    required this.summary,
    required this.article,
  });

  api.LibraryInfoShort toApiShort() {
    return api.LibraryInfoShort(
      id: id,
      title: title,
      summary: summary,
    );
  }

  api.LibraryInfoFull toApiFull(api.Presentation? presentation) {
    return api.LibraryInfoFull(
      id: id,
      title: title,
      summary: summary,
      article: article,
      presentation: presentation,
    );
  }

  factory LibraryInfo.fromJson(Map<String, dynamic> json) =>
      _$LibraryInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryInfoToJson(this);
}

@JsonSerializable()
class Categories {
  @JsonKey(name: 'smartphone')
  final bool smartphone;

  @JsonKey(name: 'smartwatch')
  final bool smartwatch;

  @JsonKey(name: 'tablet')
  final bool tablet;

  @JsonKey(name: 'laptop')
  final bool laptop;

  @JsonKey(name: 'computer')
  final bool computer;

  @JsonKey(name: 'game_console')
  final bool gameConsole;

  @JsonKey(name: 'game_controller')
  final bool gameController;

  @JsonKey(name: 'camera')
  final bool camera;

  @JsonKey(name: 'camera_lens')
  final bool cameraLens;

  @JsonKey(name: 'microprocessor')
  final bool microprocessor;

  @JsonKey(name: 'calculator')
  final bool calculator;

  @JsonKey(name: 'musical_instrument')
  final bool musicalInstrument;

  @JsonKey(name: 'washing_machine')
  final bool washingMachine;

  @JsonKey(name: 'car')
  final bool car;

  @JsonKey(name: 'motorcycle')
  final bool motorcycle;

  @JsonKey(name: 'boat')
  final bool boat;

  @JsonKey(name: 'drone')
  final bool drone;

  @JsonKey(name: 'drink')
  final bool drink;

  @JsonKey(name: 'food')
  final bool food;

  @JsonKey(name: 'toy')
  final bool toy;

  Categories({
    this.smartphone = false,
    this.smartwatch = false,
    this.tablet = false,
    this.laptop = false,
    this.computer = false,
    this.gameConsole = false,
    this.gameController = false,
    this.camera = false,
    this.cameraLens = false,
    this.microprocessor = false,
    this.calculator = false,
    this.musicalInstrument = false,
    this.washingMachine = false,
    this.car = false,
    this.motorcycle = false,
    this.boat = false,
    this.drone = false,
    this.drink = false,
    this.food = false,
    this.toy = false,
  });

  factory Categories.fromJson(Map<String, dynamic> json) =>
      _$CategoriesFromJson(json);
  Map<String, dynamic> toJson() => _$CategoriesToJson(this);
}

@JsonSerializable()
class BCorpCert {
  @JsonKey(name: 'id')
  final String id;

  BCorpCert({required this.id});

  factory BCorpCert.fromJson(Map<String, dynamic> json) =>
      _$BCorpCertFromJson(json);
  Map<String, dynamic> toJson() => _$BCorpCertToJson(this);
}

@JsonSerializable()
class EuEcolabelCert {
  @JsonKey(name: 'match_accuracy')
  final double matchAccuracy;

  EuEcolabelCert({required this.matchAccuracy});

  factory EuEcolabelCert.fromJson(Map<String, dynamic> json) =>
      _$EuEcolabelCertFromJson(json);
  Map<String, dynamic> toJson() => _$EuEcolabelCertToJson(this);
}

@JsonSerializable()
class FtiCert {
  @JsonKey(name: 'score')
  final int score;

  FtiCert({required this.score});

  factory FtiCert.fromJson(Map<String, dynamic> json) =>
      _$FtiCertFromJson(json);
  Map<String, dynamic> toJson() => _$FtiCertToJson(this);
}

@JsonSerializable()
class TcoCert {
  @JsonKey(name: 'brand_name')
  final String brandName;

  TcoCert({required this.brandName});

  factory TcoCert.fromJson(Map<String, dynamic> json) =>
      _$TcoCertFromJson(json);
  Map<String, dynamic> toJson() => _$TcoCertToJson(this);
}

@JsonSerializable()
class Certifications {
  @JsonKey(name: 'bcorp')
  final BCorpCert? bcorp;

  @JsonKey(name: 'eu_ecolabel')
  final EuEcolabelCert? euEcolabel;

  @JsonKey(name: 'tco')
  final TcoCert? tco;

  @JsonKey(name: 'fti')
  final FtiCert? fti;

  Certifications({
    required this.bcorp,
    required this.euEcolabel,
    required this.tco,
    required this.fti,
  });

  List<api.BadgeName> toBadges() {
    var badges = <api.BadgeName>[];
    if (bcorp != null) {
      badges.add(api.BadgeName.bcorp);
    }
    if (euEcolabel != null) {
      badges.add(api.BadgeName.euEcolabel);
    }
    if (tco != null) {
      badges.add(api.BadgeName.tco);
    }
    return badges;
  }

  Map<api.ScorerName, int> toScores() {
    var scores = <api.ScorerName, int>{};
    if (fti != null) {
      scores[api.ScorerName.fti] = fti!.score;
    }
    return scores;
  }

  List<api.Medallion> toMedallions() {
    var medallions = <api.Medallion>[];
    if (bcorp != null) {
      medallions.add(api.BCorpMedallion(id: bcorp!.id));
    }
    if (euEcolabel != null) {
      medallions.add(
          api.EuEcolabelMedallion(matchAccuracy: euEcolabel!.matchAccuracy));
    }
    if (tco != null) {
      medallions.add(api.TcoMedallion(brandName: tco!.brandName));
    }
    if (fti != null) {
      medallions.add(api.FtiMedallion(score: fti!.score));
    }
    return medallions;
  }

  factory Certifications.fromJson(Map<String, dynamic> json) =>
      _$CertificationsFromJson(json);
  Map<String, dynamic> toJson() => _$CertificationsToJson(this);
}

@JsonSerializable()
class Product {
  @JsonKey(name: 'id')
  final String productId;

  @JsonKey(name: 'gtins')
  final List<String> gtins;

  @JsonKey(name: 'names')
  final List<Text> names;

  @JsonKey(name: 'descriptions')
  final List<Text> descriptions;

  @JsonKey(name: 'images')
  final List<Image> images;

  @JsonKey(name: 'follows')
  final List<String> follows;

  @JsonKey(name: 'followed_by')
  final List<String> followedBy;

  @JsonKey(name: 'certifications')
  final Certifications certifications;

  Product({
    required this.productId,
    required this.gtins,
    required this.names,
    required this.descriptions,
    required this.images,
    required this.follows,
    required this.followedBy,
    required this.certifications,
  });

  api.ProductShort toApiShort() {
    return api.ProductShort(
      productId: productId,
      name: names.isNotEmpty ? names[0].text : "",
      description: descriptions.isNotEmpty ? descriptions[0].text : null,
      badges: certifications.toBadges(),
      scores: certifications.toScores(),
    );
  }

  api.ProductFull toApiFull({
    required List<api.OrganisationShort>? manufacturers,
    required List<api.CategoryAlternatives> alternatives,
  }) {
    return api.ProductFull(
      productId: productId,
      gtins: gtins,
      names: names.map((n) => n.toApi()).toList(),
      descriptions: descriptions.map((d) => d.toApi()).toList(),
      medallions: certifications.toMedallions(),
      images: images.map((i) => i.toApi()).toList(),
      manufacturers: manufacturers,
      alternatives: alternatives,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Organisation {
  @JsonKey(name: 'id')
  final String organisationId;

  @JsonKey(name: 'vat_numbers')
  final List<String>? vatNumbers;

  @JsonKey(name: 'names')
  final List<Text> names;

  @JsonKey(name: 'descriptions')
  final List<Text> descriptions;

  @JsonKey(name: 'images')
  final List<Image> images;

  @JsonKey(name: 'websites')
  final List<String> websites;

  @JsonKey(name: 'certifications')
  final Certifications certifications;

  Organisation({
    required this.organisationId,
    required this.vatNumbers,
    required this.names,
    required this.descriptions,
    required this.images,
    required this.websites,
    required this.certifications,
  });

  api.OrganisationShort toApiShort() {
    return api.OrganisationShort(
      organisationId: organisationId,
      name: names.isNotEmpty ? names[0].text : "",
      description: descriptions.isNotEmpty ? descriptions[0].text : null,
      badges: certifications.toBadges(),
      scores: certifications.toScores(),
    );
  }

  api.OrganisationFull toApiFull({
    required List<api.ProductShort> products,
  }) {
    return api.OrganisationFull(
      organisationId: organisationId,
      names: names.map((n) => n.toApi()).toList(),
      descriptions: descriptions.map((d) => d.toApi()).toList(),
      images: images.map((i) => i.toApi()).toList(),
      websites: websites,
      products: products,
      medallions: certifications.toMedallions(),
    );
  }

  factory Organisation.fromJson(Map<String, dynamic> json) =>
      _$OrganisationFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationToJson(this);
}

@JsonSerializable()
class SearchResult {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'names')
  final List<Text> names;

  SearchResult({
    required this.id,
    required this.names,
  });

  api.SearchResult toApi(api.SearchResultVariant variant) {
    return api.SearchResult(
      id: id,
      label: names.isNotEmpty ? names[0].text : "",
      variant: variant,
    );
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}
