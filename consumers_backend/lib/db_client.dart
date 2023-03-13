import 'package:arango_driver/arango_driver.dart' as arango;

import 'db_data.dart' as db;

class DbClient {
  late arango.ArangoDBClient _client;

  DbClient() {
    _client = arango.ArangoDBClient(
        scheme: 'http',
        host: 'localhost',
        port: 8529,
        db: 'consumers',
        user: '',
        pass: '');
  }

  Future<List<db.Product>> searchProducts(String tokens) async {
    final dbProducts = await _client
        .newQuery()
        .addLine('FOR p IN products_name_view')
        .addLine('  SEARCH p.name IN TOKENS(@tokens, "text_en")')
        .addLine('  RETURN p')
        .addBindVar('tokens', tokens)
        .runAndReturnFutureList();

    return dbProducts.map((p) => db.Product.fromJson(p)).toList();
  }

  Future<db.Product?> getProduct(String id) async {
    final products = await _client
        .newQuery()
        .addLine('FOR p IN products')
        .addLine('  FILTER p.id == @id')
        .addLine('  RETURN p')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    if (products.length == 1) {
      return db.Product.fromJson(products[0]);
    } else {
      return null;
    }
  }

  Future<db.Manufacturer?> getManufacturer(String id) async {
    final manufacturers = await _client
        .newQuery()
        .addLine('FOR m IN manufacturers')
        .addLine('  FILTER m.id == @id')
        .addLine('  RETURN m')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    if (manufacturers.length == 1) {
      return db.Manufacturer.fromJson(manufacturers[0]);
    } else {
      return null;
    }
  }

  Future<List<db.Product>> findAlternatives(String id) async {
    final List<dynamic> dbProducts = await _client
        .newQuery()
        .addLine('FOR p IN products')
        .addLine('  FILTER p.category == "smartphone" AND p.id != @id')
        .addLine('  LET score')
        .addLine('    = (@id IN p.follows)')
        .addLine('    + 0.99 * p.certifications.bcorp')
        .addLine('  LET randomized_score = score + 0.01 * RAND()')
        .addLine('  SORT randomized_score DESC')
        .addLine('  LIMIT 5')
        .addLine('  RETURN p')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    return dbProducts.map((p) => db.Product.fromJson(p)).toList();
  }
}
