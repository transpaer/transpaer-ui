import 'package:json_annotation/json_annotation.dart';

part 'consumers_api.g.dart';

@JsonSerializable()
class Product {
  @JsonKey(name: 'product_id')
  final String productId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'manufacturer_id')
  final String manufacturerId;

  Product(
      {required this.productId,
      required this.name,
      required this.manufacturerId});

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Manufacturer {
  @JsonKey(name: 'manufacturer_id')
  final String manufacturerId;

  @JsonKey(name: 'name')
  final String name;

  Manufacturer({required this.manufacturerId, required this.name});

  factory Manufacturer.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}

@JsonSerializable()
class TextSearchRequest {
  @JsonKey(name: 'query')
  final String query;

  @JsonKey(name: 'limit')
  final String? limit;

  TextSearchRequest({required this.query, this.limit = "10"});

  factory TextSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$TextSearchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TextSearchRequestToJson(this);
}

@JsonSerializable()
class TextSearchResponse {
  final List<Product> products;

  TextSearchResponse({required this.products});

  factory TextSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TextSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TextSearchResponseToJson(this);
}
