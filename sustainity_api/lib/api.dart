import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'api.g.dart';

@JsonSerializable()
class TextSearchRequest {
  @JsonKey(name: 'query')
  final String query;

  TextSearchRequest({required this.query});

  factory TextSearchRequest.fromJson(Map<String, dynamic> json) =>
      _$TextSearchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TextSearchRequestToJson(this);
}

@JsonSerializable()
class TextSearchResponse {
  final List<SearchResult> results;

  TextSearchResponse({required this.results});

  factory TextSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TextSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TextSearchResponseToJson(this);
}

@JsonSerializable()
class LibraryContentsResponse {
  final List<LibraryInfoShort> items;

  LibraryContentsResponse({required this.items});

  factory LibraryContentsResponse.fromJson(Map<String, dynamic> json) =>
      _$LibraryContentsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LibraryContentsResponseToJson(this);
}

@JsonSerializable()
class ProductFetchRequest {
  @JsonKey(name: 'region')
  final String? region;

  ProductFetchRequest({required this.region});

  factory ProductFetchRequest.fromJson(Map<String, dynamic> json) =>
      _$ProductFetchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ProductFetchRequestToJson(this);
}

@JsonSerializable()
class AlternativesFetchRequest {
  @JsonKey(name: 'region')
  final String? region;

  AlternativesFetchRequest({required this.region});

  factory AlternativesFetchRequest.fromJson(Map<String, dynamic> json) =>
      _$AlternativesFetchRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AlternativesFetchRequestToJson(this);
}
