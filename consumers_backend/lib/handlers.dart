import 'dart:convert';

import 'package:arango_driver/arango_driver.dart' as arango;
import 'package:shelf/shelf.dart' as shelf;

import 'package:consumers_api/consumers_api.dart' as api;

import 'db_client.dart' as db_client;
import 'db_data.dart' as db;

class SearchHandler extends Function {
  db_client.DbClient client;

  SearchHandler(this.client);

  Future<shelf.Response> call(shelf.Request req) async {
    final request =
        api.TextSearchRequest.fromJson(req.requestedUri.queryParameters);
    final dbProducts = await client.searchProducts(request.query);
    final apiProducts = dbProducts.map((p) => p.toApi()).toList();
    final response = api.TextSearchResponse(products: apiProducts);
    return shelf.Response.ok(jsonEncode(response));
  }
}

class ProductHandler extends Function {
  db_client.DbClient client;

  ProductHandler(this.client);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final dbProduct = await client.getProduct(id);
    if (dbProduct != null) {
      final apiProduct = dbProduct.toApi();
      return shelf.Response.ok(jsonEncode(apiProduct));
    } else {
      return shelf.Response.internalServerError();
    }
  }
}

class AlternativesHandler extends Function {
  db_client.DbClient client;

  AlternativesHandler(this.client);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final List<api.Product> products = [];
    return shelf.Response.ok(jsonEncode(products));
  }
}

class ManufacturersHandler extends Function {
  db_client.DbClient client;

  ManufacturersHandler(this.client);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final dbManufacturer = await client.getManufacturer(id);
    if (dbManufacturer != null) {
      final apiManufacturer = dbManufacturer.toApi();
      return shelf.Response.ok(jsonEncode(apiManufacturer));
    } else {
      return shelf.Response.internalServerError();
    }
  }
}
