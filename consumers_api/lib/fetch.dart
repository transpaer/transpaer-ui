import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data.dart';
import 'api.dart';

Future<ProductFull> fetchProduct(String id) async {
  final uri = Uri(
      scheme: 'http', host: 'localhost', port: 8080, path: '/products/' + id);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return ProductFull.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load product: ${response.statusCode}');
  }
}

Future<TextSearchResponse> searchProducts(String query) async {
  final uri = Uri(
      scheme: 'http',
      host: 'localhost',
      port: 8080,
      path: '/search',
      queryParameters: {'query': query, 'limit': '10'});
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return TextSearchResponse.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load products: ${response.statusCode}');
  }
}
