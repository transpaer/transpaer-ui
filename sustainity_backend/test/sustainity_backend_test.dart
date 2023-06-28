import 'package:test/test.dart';

import 'package:sustainity_api/sustainity_api.dart' as api;
import 'package:sustainity_backend/retrievers.dart' as retrievers;

void main() {
  test('retrievers :: ResultCollector', () {
    final r1 = api.SearchResult(
      variant: api.SearchResultVariant.organisation,
      label: "Fairphone 4",
      id: "1",
    );
    final r2 = api.SearchResult(
      variant: api.SearchResultVariant.organisation,
      label: "Samsung 4",
      id: "2",
    );
    final r3 = api.SearchResult(
      variant: api.SearchResultVariant.organisation,
      label: "Fairphone 3",
      id: "3",
    );

    var collector = retrievers.ResultCollector();
    collector.addResults([r1, r3], 0);
    collector.addResults([r1, r2], 0);

    expect(collector.gatherResults(), [r1, r3, r2]);
  });
}
