import 'package:sustainity_api/sustainity_api.dart' as api;

import 'db_client.dart' as db_client;
import 'db_data.dart' as db;

Future<List<api.CategoryAlternatives>> retrieveAlternatives(
  db_client.DbClient client,
  db.Product product,
) async {
  List<api.CategoryAlternatives> result = [];
  for (final String category in product.getCategories()) {
    List<api.ProductShort> alternatives = [];
    for (final dbProduct
        in await client.findAlternatives(product.productId, category)) {
      alternatives.add(dbProduct.toApiShort());
    }
    result.add(api.CategoryAlternatives(
      category: category,
      alternatives: alternatives,
    ));
  }

  return result;
}

Future<List<api.SearchResult>> retrieveSearchResults(
  db_client.DbClient client,
  String query,
) async {
  var ids = <String>{};
  var result = <api.SearchResult>[];
  var matches = query.split(" ");
  matches.retainWhere((match) => match != "");

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

  if (matches.length == 1) {
    final lowerCaseMatch = matches[0].toLowerCase();
    final upperCaseMatch = matches[0].toUpperCase();
    {
      final dbItems =
          await client.searchOrganisationsSubstringByVatNumber(upperCaseMatch);
      addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
    }
    {
      final dbItems =
          await client.searchProductsSubstringByGtin(lowerCaseMatch);
      addResults(ids, result, dbItems, api.SearchResultVariant.product);
    }
    {
      final dbItems =
          await client.searchOrganisationsSubstringByWebsite(lowerCaseMatch);
      addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
    }
  }

  final lowercaseMatches = matches.map((match) => match.toLowerCase()).toList();
  {
    final dbItems =
        await client.searchOrganisationsExactByKeywords(lowercaseMatches);
    addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
  }
  {
    final dbItems =
        await client.searchProductsExactByKeywords(lowercaseMatches);
    addResults(ids, result, dbItems, api.SearchResultVariant.product);
  }

  return result;
}
