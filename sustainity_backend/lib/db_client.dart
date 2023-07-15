import 'package:arango_driver/arango_driver.dart' as arango;

import 'db_data.dart' as db;

class DbClient {
  late arango.DbClient _client;

  DbClient({
    required String host,
    required String user,
    required String password,
  }) {
    _client = arango.DbClient(
      scheme: 'http',
      host: host,
      port: 8529,
      db: 'sustainity',
      user: user,
      pass: password,
    );
  }

  Future<List<db.SearchResult>> searchOrganisationsExactByKeyword(
    String match,
  ) async {
    final dbOrganisations = await _client
        .newQuery()
        .addLine(
            'WITH organisations, organisation_keywords, organisation_keyword_edges')
        .addLine('FOR k IN organisation_keywords')
        .addLine('  FILTER k.keyword == @match')
        .addLine('  FOR o IN 1..1 OUTBOUND k organisation_keyword_edges')
        .addLine('    RETURN o')
        .addBindVar('match', match)
        .runAndReturnFutureList();

    return dbOrganisations.map((p) => db.SearchResult.fromJson(p)).toList();
  }

  Future<List<db.SearchResult>> searchOrganisationsSubstringByWebsite(
    String match,
  ) async {
    final dbOrganisations = await _client
        .newQuery()
        .addLine('FOR o IN organisations')
        .addLine('  FILTER o.websites[? 1')
        .addLine('      FILTER CONTAINS(CURRENT, @match)')
        .addLine('    ]')
        .addLine('  RETURN { id: o.id, names: o.names }')
        .addBindVar('match', match)
        .runAndReturnFutureList();

    return dbOrganisations.map((p) => db.SearchResult.fromJson(p)).toList();
  }

  Future<List<db.SearchResult>> searchOrganisationsSubstringByVatNumber(
    String match,
  ) async {
    final dbOrganisations = await _client
        .newQuery()
        .addLine('FOR o IN organisations')
        .addLine('  FILTER o.vat_numbers[? 1')
        .addLine('      FILTER CONTAINS(CURRENT, @match)')
        .addLine('    ]')
        .addLine('  RETURN { id: o.id, names: o.names }')
        .addBindVar('match', match)
        .runAndReturnFutureList();

    return dbOrganisations.map((p) => db.SearchResult.fromJson(p)).toList();
  }

  Future<List<db.SearchResult>> searchProductsExactByKeyword(
    String match,
  ) async {
    final dbProducts = await _client
        .newQuery()
        .addLine('WITH products, product_keywords, product_keyword_edges')
        .addLine('FOR k IN product_keywords')
        .addLine('  FILTER k.keyword == @match')
        .addLine('  FOR p IN 1..1 OUTBOUND k product_keyword_edges')
        .addLine('    RETURN p')
        .addBindVar('match', match)
        .runAndReturnFutureList();

    return dbProducts.map((p) => db.SearchResult.fromJson(p)).toList();
  }

  Future<List<db.SearchResult>> searchProductsSubstringByGtin(
    String match,
  ) async {
    final dbProducts = await _client
        .newQuery()
        .addLine('WITH products, gtins, gtin_edges')
        .addLine('FOR g IN gtins')
        .addLine('  FILTER g._key == @match')
        .addLine('  FOR p IN 1..1 OUTBOUND g gtin_edges')
        .addLine('    RETURN p')
        .addBindVar('match', match)
        .runAndReturnFutureList();

    return dbProducts.map((p) => db.SearchResult.fromJson(p)).toList();
  }

  Future<db.LibraryInfo?> getLibraryInfo(String id) async {
    final infos = await _client
        .newQuery()
        .addLine('FOR i IN library')
        .addLine('  FILTER i.id == @id')
        .addLine('  RETURN i')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    if (infos.length == 1) {
      return db.LibraryInfo.fromJson(infos[0]);
    } else {
      return null;
    }
  }

  Future<List<db.LibraryInfo>> getLibraryContents() async {
    final items = await _client
        .newQuery()
        .addLine('FOR i IN library')
        .addLine('  RETURN i')
        .runAndReturnFutureList();

    return items.map((i) => db.LibraryInfo.fromJson(i)).toList();
  }

  Future<db.Presentation?> getPresentation(String id) async {
    final presentations = await _client
        .newQuery()
        .addLine('FOR p IN presentations')
        .addLine('  FILTER p.id == @id')
        .addLine('  RETURN p')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    if (presentations.length == 1) {
      return db.Presentation.fromJson(presentations[0]);
    } else {
      return null;
    }
  }

  Future<db.Organisation?> getOrganisation(String id) async {
    final organisations = await _client
        .newQuery()
        .addLine('FOR o IN organisations')
        .addLine('  FILTER o.id == @id')
        .addLine('  RETURN o')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    if (organisations.length == 1) {
      return db.Organisation.fromJson(organisations[0]);
    } else {
      return null;
    }
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

  Future<List<db.Product>> findOrganisationProducts(String id) async {
    Stopwatch stopwatch = new Stopwatch()..start();
    final List<dynamic> dbProducts = await _client
        .newQuery()
        .addLine('WITH organisations, products, manufacturing_edges')
        .addLine('FOR o IN organisations')
        .addLine('  FILTER o.id == @id')
        .addLine('  FOR p IN 1..1 OUTBOUND o manufacturing_edges')
        .addLine('    RETURN p')
        .addBindVar('id', id)
        .runAndReturnFutureList();
    print('org pro ${stopwatch.elapsed}');
    return dbProducts.map((p) => db.Product.fromJson(p)).toList();
  }

  Future<List<db.Organisation>> findProductManufacturers(String id) async {
    Stopwatch stopwatch = Stopwatch()..start();
    final List<dynamic> dbOrganisations = await _client
        .newQuery()
        .addLine('WITH organisations, products, manufacturing_edges')
        .addLine('FOR p IN products')
        .addLine('  FILTER p.id == @id')
        .addLine('  FOR o IN 1..1 INBOUND p manufacturing_edges')
        .addLine('    RETURN o')
        .addBindVar('id', id)
        .runAndReturnFutureList();
    print('org pro ${stopwatch.elapsed}');

    return dbOrganisations.map((p) => db.Organisation.fromJson(p)).toList();
  }

  Future<List<String>> findCategories(String id) async {
    final List<dynamic> dbCategories = await _client
        .newQuery()
        .addLine('WITH categories, products, category_edges')
        .addLine('FOR p IN products')
        .addLine('  FILTER p.id == @id')
        .addLine('  FOR c IN 1..1 INBOUND p category_edges')
        .addLine('    RETURN c')
        .addBindVar('id', id)
        .runAndReturnFutureList();

    return dbCategories.map((c) => c['_key'] as String).toList();
  }

  Future<List<db.Product>> findAlternatives(String id, String category) async {
    final List<dynamic> dbProducts = await _client
        .newQuery()
        .addLine('WITH categories, products, category_edges')
        .addLine('FOR c IN categories')
        .addLine('  FILTER c._key == @category')
        .addLine('  FOR p IN 1..1 OUTBOUND c category_edges')
        .addLine('    FILTER p.id != @id')
        .addLine('    LET score')
        .addLine('      = (@id IN p.follows)')
        .addLine('      + 0.90 * (p.certifications.bcorp != null)')
        .addLine('      + 0.90 * (p.certifications.eu_ecolabel != null)')
        .addLine('      + 0.60 * 0.01 * p.certifications.fti.score')
        .addLine('      + 0.30 * (p.certifications.tco != null)')
        .addLine('    LET randomized_score = score + 0.01 * RAND()')
        .addLine('    SORT randomized_score DESC')
        .addLine('    LIMIT 10')
        .addLine('    RETURN p')
        .addBindVar('id', id)
        .addBindVar('category', category)
        .runAndReturnFutureList();

    return dbProducts.map((p) => db.Product.fromJson(p)).toList();
  }
}
