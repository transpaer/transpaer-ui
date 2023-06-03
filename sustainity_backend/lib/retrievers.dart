import 'package:sustainity_api/sustainity_api.dart' as api;

import 'db_client.dart' as db_client;
import 'db_data.dart' as db;

Future<List<api.ProductShort>> retrieveAlternatives(
    db_client.DbClient client, db.Product product) async {
  List<api.ProductShort> alternatives = [];
  final String? category = product.getCategory();
  if (category == null) {
    return alternatives;
  }
  for (final dbProduct
      in await client.findAlternatives(product.productId, category)) {
    alternatives.add(dbProduct.toApiShort());
  }

  return alternatives;
}
