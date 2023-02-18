import 'dart:convert';

import 'package:arango_driver/arango_driver.dart' as arango;
import 'package:shelf/shelf.dart' as shelf;

import 'package:consumers_api/consumers_api.dart' as api;

import 'db_data.dart' as db;

class SearchHandler extends Function {
  arango.ArangoDBClient client;

  SearchHandler(this.client);

  Future<shelf.Response> call(shelf.Request req) async {
    final request =
        api.TextSearchRequest.fromJson(req.requestedUri.queryParameters);
    final dbProducts = await client
        .newQuery()
        .addLine('FOR p IN product_names')
        .addLineIfThen(true,
            'SEARCH ANALYZER(p.name IN TOKENS(@query, "text_en"), "text_en")')
        .addLine('RETURN p')
        .addBindVarIfThen(true, 'query', request.query)
        .runAndReturnFutureList();
    final apiProducts =
        dbProducts.map((p) => db.Product.fromJson(p).toApi()).toList();
    final response = api.TextSearchResponse(products: apiProducts);
    return shelf.Response.ok(jsonEncode(response));
  }
}

class ProductHandler extends Function {
  arango.ArangoDBClient client;

  ProductHandler(this.client);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final products = await client
        .newQuery()
        .addLine('FOR p IN products')
        .addLineIfThen(true, 'FILTER p.id == @id')
        .addLine('RETURN p')
        .addBindVarIfThen(true, 'id', id)
        .runAndReturnFutureList();
    if (products.length == 1) {
      final apiProduct = db.Product.fromJson(products[0]).toApi();
      return shelf.Response.ok(jsonEncode(apiProduct));
    } else {
      return shelf.Response.internalServerError();
    }
  }
}

class AlternativesHandler extends Function {
  arango.ArangoDBClient client;

  AlternativesHandler(this.client);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final List<api.Product> products = [];
    return shelf.Response.ok(jsonEncode(products));
  }
}

class ManufacturersHandler extends Function {
  arango.ArangoDBClient client;

  ManufacturersHandler(this.client);

  Future<shelf.Response> call(shelf.Request req, String id) async {
    final manufacturers = await client
        .newQuery()
        .addLine('FOR m IN manufacturers')
        .addLineIfThen(true, 'FILTER m.id == @id')
        .addLine('RETURN m')
        .addBindVarIfThen(true, 'id', id)
        .runAndReturnFutureList();
    if (manufacturers.length == 1) {
      final dbManufacturer = manufacturers[0];
      final apiManufacturer = api.Manufacturer(
          manufacturerId: dbManufacturer['id'], name: dbManufacturer['name']);
      return shelf.Response.ok(jsonEncode(apiManufacturer));
    } else {
      return shelf.Response.internalServerError();
    }
  }
}
