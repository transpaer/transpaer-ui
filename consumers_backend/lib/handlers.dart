import 'dart:convert';

import 'package:shelf/shelf.dart' as shelf;

import 'package:consumers_api/consumers_api.dart' as api;

import 'db_client.dart' as db_client;
import 'retrievers.dart' as retrievers;

class SearchHandler {
  db_client.DbClient client;
  JsonEncoder encoder;

  SearchHandler(this.client, this.encoder);

  Future<shelf.Response> call(shelf.Request req) async {
    final request =
        api.TextSearchRequest.fromJson(req.requestedUri.queryParameters);
    final dbProducts = await client.searchProducts(request.query);
    final apiProducts = dbProducts.map((p) => p.toApiFull()).toList();
    final response = api.TextSearchResponse(products: apiProducts);
    return shelf.Response.ok(encoder.convert(response));
  }
}

class ProductHandler {
  db_client.DbClient client;
  JsonEncoder encoder;

  ProductHandler(this.client, this.encoder);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final dbProduct = await client.getProduct(id);
    if (dbProduct != null) {
      List<api.Manufacturer>? apiManufacturers;
      if (dbProduct.manufacturerIds != null) {
        apiManufacturers = [];
        for (final manufacturerId in dbProduct.manufacturerIds!) {
          final dbManufacturer = await client.getManufacturer(manufacturerId);
          if (dbManufacturer != null) {
            apiManufacturers.add(dbManufacturer.toApi());
          }
        }
      }

      final List<api.ProductShort> alternatives =
          await retrievers.retrieveAlternatives(client, dbProduct);
      final apiProduct = dbProduct.toApiFull(
          manufacturers: apiManufacturers, alternatives: alternatives);

      return shelf.Response.ok(encoder.convert(apiProduct));
    } else {
      return shelf.Response.notFound(null);
    }
  }
}

class AlternativesHandler {
  db_client.DbClient client;
  JsonEncoder encoder;

  AlternativesHandler(this.client, this.encoder);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final dbProduct = await client.getProduct(id);
    if (dbProduct != null) {
      final List<api.ProductShort> products =
          await retrievers.retrieveAlternatives(client, dbProduct);
      return shelf.Response.ok(encoder.convert(products));
    } else {
      return shelf.Response.notFound(null);
    }
  }
}

class ManufacturersHandler {
  db_client.DbClient client;
  JsonEncoder encoder;

  ManufacturersHandler(this.client, this.encoder);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final dbManufacturer = await client.getManufacturer(id);
    if (dbManufacturer != null) {
      final apiManufacturer = dbManufacturer.toApi();
      return shelf.Response.ok(encoder.convert(apiManufacturer));
    } else {
      return shelf.Response.notFound(null);
    }
  }
}
