import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'api.g.dart';

@JsonSerializable()
class OrganisationTextSearchRequest {
  @JsonKey(name: 'query')
  final String query;

  @JsonKey(name: 'limit')
  final String? limit;

  OrganisationTextSearchRequest({required this.query, this.limit = "10"});

  factory OrganisationTextSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$OrganisationTextSearchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationTextSearchRequestToJson(this);
}

@JsonSerializable()
class OrganisationTextSearchResponse {
  final List<Organisation> organisations;

  OrganisationTextSearchResponse({required this.organisations});

  factory OrganisationTextSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$OrganisationTextSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$OrganisationTextSearchResponseToJson(this);
}

@JsonSerializable()
class ProductTextSearchRequest {
  @JsonKey(name: 'query')
  final String query;

  @JsonKey(name: 'limit')
  final String? limit;

  ProductTextSearchRequest({required this.query, this.limit = "10"});

  factory ProductTextSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$ProductTextSearchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProductTextSearchRequestToJson(this);
}

@JsonSerializable()
class ProductTextSearchResponse {
  final List<ProductFull> products;

  ProductTextSearchResponse({required this.products});

  factory ProductTextSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductTextSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductTextSearchResponseToJson(this);
}
