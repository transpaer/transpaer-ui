import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data.dart';
import 'api.dart';

class Fetcher {
  final String scheme;
  final String host;
  final int port;

  Fetcher({required this.scheme, required this.host, required this.port});

  Future<Info> fetchInfo(InfoTopic topic) async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/info/' + topic.name,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Info.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load info: ${response.statusCode}');
    }
  }

  Future<Organisation> fetchOrganisation(String id) async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/organisation/' + id,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return Organisation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load organisation: ${response.statusCode}');
    }
  }

  Future<OrganisationTextSearchResponse> searchOrganisations(
      String query) async {
    final uri = Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: '/search/organisations',
        queryParameters: {'query': query, 'limit': '10'});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return OrganisationTextSearchResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load organisations: ${response.statusCode}');
    }
  }

  Future<ProductFull> fetchProduct(String id) async {
    final uri = Uri(
      scheme: scheme,
      host: host,
      port: port,
      path: '/product/' + id,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ProductFull.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  Future<ProductTextSearchResponse> searchProducts(String query) async {
    final uri = Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: '/search/products',
        queryParameters: {'query': query, 'limit': '10'});
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return ProductTextSearchResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }
}
