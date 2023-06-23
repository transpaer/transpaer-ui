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

  @JsonKey(name: 'article')
  final String article;

  LibraryInfo({required this.id, required this.title, required this.article});

  api.LibraryInfo toApi(api.Presentation? presentation) {
    return api.LibraryInfo(
      id: id,
      title: title,
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
class Certifications {
  @JsonKey(name: 'bcorp')
  final bool bcorp;

  @JsonKey(name: 'eu_ecolabel')
  final bool euEcolabel;

  @JsonKey(name: 'tco')
  final bool tco;

  @JsonKey(name: 'fti')
  final int? fti;

  Certifications({
    required this.bcorp,
    required this.euEcolabel,
    required this.tco,
    required this.fti,
  });

  List<api.BadgeName> toBadges() {
    var badges = <api.BadgeName>[];
    if (bcorp) {
      badges.add(api.BadgeName.bcorp);
    }
    if (euEcolabel) {
      badges.add(api.BadgeName.euEcolabel);
    }
    if (tco) {
      badges.add(api.BadgeName.tco);
    }
    return badges;
  }

  Map<api.ScorerName, int> toScores() {
    var scores = <api.ScorerName, int>{};
    if (fti != null) {
      scores[api.ScorerName.fti] = fti!;
    }
    return scores;
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

  @JsonKey(name: 'categories')
  final Categories categories;

  @JsonKey(name: 'images')
  final List<Image> images;

  @JsonKey(name: 'manufacturer_ids')
  final List<String> manufacturerIds;

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
    required this.categories,
    required this.images,
    required this.manufacturerIds,
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
      badges: certifications.toBadges(),
      scores: certifications.toScores(),
      images: images.map((i) => i.toApi()).toList(),
      manufacturers: manufacturers,
      alternatives: alternatives,
    );
  }

  List<String> getCategories() {
    var result = <String>[];
    if (categories.smartphone) {
      result.add('smartphone');
    }
    if (categories.smartwatch) {
      result.add('smartwatch');
    }
    if (categories.tablet) {
      result.add('tablet');
    }
    if (categories.laptop) {
      result.add('laptop');
    }
    if (categories.computer) {
      result.add('computer');
    }
    if (categories.gameConsole) {
      result.add('game_console');
    }
    if (categories.gameController) {
      result.add('game_controller');
    }
    if (categories.camera) {
      result.add('camera');
    }
    if (categories.cameraLens) {
      result.add('camera_lens');
    }
    if (categories.microprocessor) {
      result.add('microprocessor');
    }
    if (categories.calculator) {
      result.add('calculator');
    }
    if (categories.musicalInstrument) {
      result.add('musical_instrument');
    }
    if (categories.washingMachine) {
      result.add('washing_machine');
    }
    if (categories.car) {
      result.add('car');
    }
    if (categories.motorcycle) {
      result.add('motorcycle');
    }
    if (categories.boat) {
      result.add('boat');
    }
    if (categories.drone) {
      result.add('drone');
    }
    if (categories.drink) {
      result.add('drink');
    }
    if (categories.food) {
      result.add('food');
    }
    if (categories.toy) {
      result.add('toy');
    }
    return result;
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
      badges: certifications.toBadges(),
      scores: certifications.toScores(),
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
