import 'package:json_annotation/json_annotation.dart';

import 'package:sustainity_api/sustainity_api.dart' as api;

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

  @JsonKey(name: 'tco')
  final bool tco;

  @JsonKey(name: 'fti')
  final int? fti;

  Certifications({required this.bcorp, required this.tco, required this.fti});

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

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'categories')
  final Categories categories;

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
    required this.categories,
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
      scores: certifications.toScores(),
    );
  }

  api.ProductFull toApiFull({
    List<api.Organisation>? manufacturers,
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

  String? getCategory() {
    if (categories.smartphone) {
      return 'smartphone';
    }
    if (categories.smartwatch) {
      return 'smartwatch';
    }
    if (categories.tablet) {
      return 'tablet';
    }
    if (categories.laptop) {
      return 'laptop';
    }
    if (categories.computer) {
      return 'computer';
    }
    if (categories.gameConsole) {
      return 'game_console';
    }
    if (categories.gameController) {
      return 'game_controller';
    }
    if (categories.camera) {
      return 'camera';
    }
    if (categories.cameraLens) {
      return 'camera_lens';
    }
    if (categories.microprocessor) {
      return 'microprocessor';
    }
    if (categories.calculator) {
      return 'calculator';
    }
    if (categories.musicalInstrument) {
      return 'musical_instrument';
    }
    if (categories.car) {
      return 'car';
    }
    if (categories.motorcycle) {
      return 'motorcycle';
    }
    if (categories.boat) {
      return 'boat';
    }
    if (categories.drone) {
      return 'drone';
    }
    if (categories.drink) {
      return 'drink';
    }
    if (categories.food) {
      return 'food';
    }
    if (categories.toy) {
      return 'toy';
    }
    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Organisation {
  @JsonKey(name: 'id')
  final String organisationId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'certifications')
  final Certifications certifications;

  Organisation({
    required this.organisationId,
    required this.name,
    required this.description,
    required this.certifications,
  });

  api.Organisation toApi() {
    return api.Organisation(
        organisationId: organisationId,
        name: name,
        description: description,
        badges: certifications.toBadges(),
        scores: certifications.toScores());
  }

  factory Organisation.fromJson(Map<String, dynamic> json) =>
      _$OrganisationFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationToJson(this);
}
