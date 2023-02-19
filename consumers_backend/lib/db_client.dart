import 'package:arango_driver/arango_driver.dart' as arango;

import 'db_data.dart' as db;

class DbClient {
  late arango.ArangoDBClient _client;

  DbClient() {
    _client = arango.ArangoDBClient(
        scheme: 'http',
        host: 'localhost',
        port: 8529,
        db: '_system',
        user: '',
        pass: '');
  }

  Future<List<db.Product>> searchProducts(String tokens) async {
    final dbProducts = await _client
        .newQuery()
        .addLine('FOR p IN product_names')
        .addLineIfThen(true,
            'SEARCH ANALYZER(p.name IN TOKENS(@tokens, "text_en"), "text_en")')
        .addLine('RETURN p')
        .addBindVarIfThen(true, 'tokens', tokens)
        .runAndReturnFutureList();

    return dbProducts.map((p) => db.Product.fromJson(p)).toList();
  }

  Future<db.Product?> getProduct(String id) async {
    final products = await _client
        .newQuery()
        .addLine('FOR p IN products')
        .addLineIfThen(true, 'FILTER p.id == @id')
        .addLine('RETURN p')
        .addBindVarIfThen(true, 'id', id)
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
        .addLineIfThen(true, 'FILTER m.id == @id')
        .addLine('RETURN m')
        .addBindVarIfThen(true, 'id', id)
        .runAndReturnFutureList();

    if (manufacturers.length == 1) {
      return db.Manufacturer.fromJson(manufacturers[0]);
    } else {
      return null;
    }
  }
}
