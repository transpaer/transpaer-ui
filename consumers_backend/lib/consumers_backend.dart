import 'dart:convert';

import 'package:arango_driver/arango_driver.dart' as arango;
import 'package:shelf/shelf.dart' as shelf;

import 'package:consumers_api/consumers_api.dart' as api;

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
      final dbProduct = products[0];
      final apiProduct = api.Product(
          product_id: dbProduct['id'],
          name: dbProduct['name'],
          manufacturer_id: 'B');
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
          manufacturer_id: dbManufacturer['id'], name: dbManufacturer['name']);
      return shelf.Response.ok(jsonEncode(apiManufacturer));
    } else {
      return shelf.Response.internalServerError();
    }
  }
}
