import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data.dart';
import 'api.dart';

class Fetcher {
  final String scheme;
  final String host;
  final int port;

  Fetcher({required this.scheme, required this.host, required this.port});

  Future<LibraryContentsResponse> fetchLibraryContents() async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: "/library",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return LibraryContentsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to load library contents: ${response.statusCode}',
      );
    }
  }

  Future<LibraryInfoFull> fetchLibraryInfo(LibraryTopic topic) async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: "/library/${topic.name}",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return LibraryInfoFull.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load library item: ${response.statusCode}');
    }
  }

  Future<OrganisationFull> fetchOrganisation(String id) async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: "/organisation/$id",
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return OrganisationFull.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load organisation: ${response.statusCode}');
    }
  }

  Future<ProductFull> fetchProduct(
    String id,
    String? regionCode,
  ) async {
    var params = <String, String>{};
    if (regionCode != null) {
      params["region"] = regionCode;
    }

    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: "/product/$id",
      queryParameters: params,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ProductFull.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<TextSearchResponse> textSearch(String query) async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/search/text',
      queryParameters: {'query': query},
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return TextSearchResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }
}
