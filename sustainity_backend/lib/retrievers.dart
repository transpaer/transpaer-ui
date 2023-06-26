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
      Stopwatch stopwatch = new Stopwatch()..start();
      final dbItems =
          await client.searchOrganisationsSubstringByVatNumber(upperCaseMatch);
      addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
      print('XXX org vat ${stopwatch.elapsed}');
    }
    if (lowerCaseMatch.length < 15) {
      final match = lowerCaseMatch.padLeft(14, '0');
      Stopwatch stopwatch = new Stopwatch()..start();
      final dbItems = await client.searchProductsSubstringByGtin(match);
      addResults(ids, result, dbItems, api.SearchResultVariant.product);
      print('XXX pro tin ${stopwatch.elapsed}');
    }
    {
      Stopwatch stopwatch = new Stopwatch()..start();
      final dbItems =
          await client.searchOrganisationsSubstringByWebsite(lowerCaseMatch);
      addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
      print('XXX org web ${stopwatch.elapsed}');
    }
  }

  final lowercaseMatches = matches.map((match) => match.toLowerCase()).toList();
  {
    Stopwatch stopwatch = new Stopwatch()..start();
    for (final match in lowercaseMatches) {
      final dbItems = await client.searchOrganisationsExactByKeyword(match);
      addResults(ids, result, dbItems, api.SearchResultVariant.organisation);
    }
    print('XXX org key ${stopwatch.elapsed}');
  }
  {
    Stopwatch stopwatch = new Stopwatch()..start();
    for (final match in lowercaseMatches) {
      final dbItems = await client.searchProductsExactByKeyword(match);
      addResults(ids, result, dbItems, api.SearchResultVariant.product);
    }
    print('XXX pro key ${stopwatch.elapsed}');
  }

  return result;
}
