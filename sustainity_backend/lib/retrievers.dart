import 'package:sustainity_api/sustainity_api.dart' as api;

import 'db_client.dart' as db_client;
import 'db_data.dart' as db;

class ScoredResult {
  double score;
  api.SearchResult result;

  ScoredResult({required this.score, required this.result});

  ScoredResult withAddedScore(double s) {
    return ScoredResult(score: score + s, result: result);
  }
}

class ResultCollector {
  Map<String, ScoredResult> results;

  ResultCollector() : results = <String, ScoredResult>{};

  void addResults(List<api.SearchResult> items, int? index) {
    var score = 0.0;
    if (index != null) {
      score = 1.0 + 1.0 / (index + 1);
    } else {
      score == 10.0;
    }
    for (final r in items) {
      results.update(
        r.id,
        (current) => current.withAddedScore(score),
        ifAbsent: () => ScoredResult(score: score, result: r),
      );
    }
  }

  List<api.SearchResult> gatherResults() {
    List<ScoredResult> result = results.values.toList();
    result.sort((a, b) => b.score.compareTo(a.score));
    if (result.length > 20) {
      result = result.sublist(0, 20);
    }
    return result.map((r) => r.result).toList();
  }
}

Future<List<api.CategoryAlternatives>> retrieveAlternatives(
  db_client.DbClient client,
  db.Product product,
) async {
  List<api.CategoryAlternatives> result = [];
  for (final String category
      in await client.findCategories(product.productId)) {
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
  var collector = ResultCollector();
  var matches = query.split(" ");
  matches.retainWhere((match) => match != "");

  if (matches.length == 1) {
    final lowerCaseMatch = matches[0].toLowerCase();
    final upperCaseMatch = matches[0].toUpperCase();
    {
      final variant = api.SearchResultVariant.organisation;
      final dbItems =
          await client.searchOrganisationsSubstringByVatNumber(upperCaseMatch);
      final apiItems = dbItems.map((r) => r.toApi(variant)).toList();
      collector.addResults(apiItems, null);
    }
    if (lowerCaseMatch.length < 15) {
      final variant = api.SearchResultVariant.product;
      final match = lowerCaseMatch.padLeft(14, '0');
      final dbItems = await client.searchProductsSubstringByGtin(match);
      final apiItems = dbItems.map((r) => r.toApi(variant)).toList();
      collector.addResults(apiItems, null);
    }
    {
      final variant = api.SearchResultVariant.organisation;
      final dbItems =
          await client.searchOrganisationsSubstringByWebsite(lowerCaseMatch);
      final apiItems = dbItems.map((r) => r.toApi(variant)).toList();
      collector.addResults(apiItems, null);
    }
  }

  final lowercaseMatches = matches.map((match) => match.toLowerCase()).toList();
  {
    final variant = api.SearchResultVariant.organisation;
    var index = 0;
    for (final match in lowercaseMatches) {
      final dbItems = await client.searchOrganisationsExactByKeyword(match);
      final apiItems = dbItems.map((r) => r.toApi(variant)).toList();
      collector.addResults(apiItems, index);
      index += 1;
    }
  }
  {
    final variant = api.SearchResultVariant.product;
    var index = 0;
    for (final match in lowercaseMatches) {
      final dbItems = await client.searchProductsExactByKeyword(match);
      final apiItems = dbItems.map((r) => r.toApi(variant)).toList();
      collector.addResults(apiItems, index);
      index += 1;
    }
  }

  return collector.gatherResults();
}
