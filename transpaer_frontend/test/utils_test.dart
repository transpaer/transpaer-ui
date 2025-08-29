// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import 'package:flutter_test/flutter_test.dart';

import 'package:transpaer_frontend/main.dart';
import 'package:transpaer_api/api.dart' as api;

void main() {
  test('OrganisationLink fromSlug', () {
    final parsed1 = OrganisationLink.fromSlug("qwerty");
    expect(parsed1, null);

    final parsed2 = OrganisationLink.fromSlug("qwerty:uiop");
    expect(parsed2, null);

    final parsed3 = OrganisationLink.fromSlug("wiki:1234")!;
    expect(parsed3.variant, api.OrganisationIdVariant.wiki);
    expect(parsed3.id, "1234");

    final parsed4 = OrganisationLink.fromSlug("vat:1234")!;
    expect(parsed4.variant, api.OrganisationIdVariant.vat);
    expect(parsed4.id, "1234");

    final parsed5 = OrganisationLink.fromSlug("www:example.com")!;
    expect(parsed5.variant, api.OrganisationIdVariant.www);
    expect(parsed5.id, "example.com");
  });

  test('ProductLink fromSlug', () {
    final parsed1 = ProductLink.fromSlug("qwerty");
    expect(parsed1, null);

    final parsed2 = ProductLink.fromSlug("qwerty:uiop");
    expect(parsed2, null);

    final parsed3 = ProductLink.fromSlug("wiki:1234")!;
    expect(parsed3.variant, api.ProductIdVariant.wiki);
    expect(parsed3.id, "1234");

    final parsed4 = ProductLink.fromSlug("ean:1234")!;
    expect(parsed4.variant, api.ProductIdVariant.ean);
    expect(parsed4.id, "1234");

    final parsed5 = ProductLink.fromSlug("gtin:1234")!;
    expect(parsed5.variant, api.ProductIdVariant.gtin);
    expect(parsed5.id, "1234");
  });
}
