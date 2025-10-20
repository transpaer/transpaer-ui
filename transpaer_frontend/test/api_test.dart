// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';

import 'package:transpaer_frontend/main.dart';
import 'package:transpaer_api/api.dart' as api;

void main() {
  test('DataSources', () {
    expect(dataSourceValues.length, api.DataSource.values.length);
  });

  test('BadgeName', () {
    expect(badgeNameValues.length, api.BadgeName.values.length);
  });

  test('ScorerName', () {
    expect(scorerNameValues.length, api.ScorerName.values.length);
  });

  test('TranspaerScoreCategory', () {
    expect(transpaerScoreBranchesInfos.length,
        api.TranspaerScoreCategory.values.length);
  });

  test('Deserialize TextSearchResult with an organisation', () {
    final parsed = api.TextSearchResult.fromJson({
      "label": "LABEL",
      "link": {
        "id": "ID",
        "organisation_id_variant": "wiki",
      }
    });

    final expected = api.TextSearchResult(
        label: "LABEL",
        link: api.TextSearchLinkHack(
          id: "ID",
          organisationIdVariant: api.OrganisationIdVariant.wiki,
          productIdVariant: null,
        ));

    expect(parsed, expected);
  });

  test('Deserialize TextSearchResult with a product', () {
    final parsed = api.TextSearchResult.fromJson({
      "label": "LABEL",
      "link": {
        "id": "ID",
        "product_id_variant": "gtin",
      }
    });

    final expected = api.TextSearchResult(
        label: "LABEL",
        link: api.TextSearchLinkHack(
          id: "ID",
          productIdVariant: api.ProductIdVariant.gtin,
          organisationIdVariant: null,
        ));

    expect(parsed, expected);
  });

  test('Convert TextSearchLink', () {
    final original1 = api.TextSearchLinkHack(
      id: "ID",
      organisationIdVariant: api.OrganisationIdVariant.wiki,
      productIdVariant: null,
    );

    final original2 = api.TextSearchLinkHack(
      id: "ID",
      productIdVariant: api.ProductIdVariant.gtin,
      organisationIdVariant: null,
    );

    final expected1 =
        OrganisationLink(id: "ID", variant: api.OrganisationIdVariant.wiki);
    final expected2 = ProductLink(id: "ID", variant: api.ProductIdVariant.gtin);

    final converted1 = TextSearchLink.fromApi(original1);
    final converted2 = TextSearchLink.fromApi(original2);

    expect(converted1.id, expected1.id);
    expect(converted1.variant, expected1.variant);

    expect(converted2.id, expected2.id);
    expect(converted2.variant, expected2.variant);
  });
}
