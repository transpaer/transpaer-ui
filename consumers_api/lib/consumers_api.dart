import 'package:json_annotation/json_annotation.dart';

part 'consumers_api.g.dart';

@JsonSerializable()
class Product {
  final String product_id;
  final String name;
  final String manufacturer_id;

  Product(
      {required this.product_id,
      required this.name,
      required this.manufacturer_id});

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}

@JsonSerializable()
class Manufacturer {
  final String manufacturer_id;
  final String name;

  Manufacturer({required this.manufacturer_id, required this.name});

  factory Manufacturer.fromJson(Map<String, dynamic> json) =>
      _$ManufacturerFromJson(json);
  Map<String, dynamic> toJson() => _$ManufacturerToJson(this);
}
