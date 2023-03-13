import 'package:consumers_api/consumers_api.dart' as api;

import 'db_client.dart' as db_client;
import 'db_data.dart' as db;

Future<List<api.ProductShort>> retrieveAlternatives(
    db_client.DbClient client, db.Product product) async {
  List<api.ProductShort> alternatives = [];
  for (final dbProduct in await client.findAlternatives(product.productId)) {
    alternatives.add(dbProduct.toApiShort());
  }

  return alternatives;
}
