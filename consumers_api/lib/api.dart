import 'package:json_annotation/json_annotation.dart';

import 'data.dart';

part 'api.g.dart';

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
  final List<ProductFull> products;

  TextSearchResponse({required this.products});

  factory TextSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$TextSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TextSearchResponseToJson(this);
}
