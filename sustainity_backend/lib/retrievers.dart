import 'package:sustainity_api/sustainity_api.dart' as api;

import 'db_client.dart' as db_client;
import 'db_data.dart' as db;

Future<List<api.ProductShort>> retrieveAlternatives(
  db_client.DbClient client,
  db.Product product,
) async {
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

Future<List<api.SearchResult>> retrieveSearchResults(
  db_client.DbClient client,
  String query,
) async {
  var ids = <String>{};
  var result = <api.SearchResult>[];

  void addResults(
    Set<String> ids,
    List<api.SearchResult> result,
    List<db.SearchResult> items,
    api.SearchResultVariant variant,
  ) {
    for (final r in items) {
      if (!ids.contains(r.id)) {
        result.add(r.toApi(variant));
        ids.add(r.id);
      }
    }
  }

  {
    final dbItems = await client.searchOrganisationsSubstringByWebsite(query);
    addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
  }
  {
    final dbItems = await client.searchProductsExactByName(query);
    addResults(ids, result, dbItems, api.SearchResultVariant.product);
  }
  {
    final dbItems = await client.searchOrganisationsExactByName(query);
    addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
  }

  if (query.length > 5) {
    if (result.length < 20) {
      final dbItems = await client.searchProductsFuzzyByName(query);
      addResults(ids, result, dbItems, api.SearchResultVariant.product);
    }

    if (result.length < 20) {
      final dbItems = await client.searchOrganisationsFuzzyByName(query);
      addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
    }
  }

  return result;
}
