// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:sustainity_frontend/main.dart';
import 'package:sustainity_api/api.dart' as api;

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

  test('TextSearchResultVariant', () {
    expect(searchResultVariantValues.length,
        api.TextSearchResultVariant.values.length);
  });

  test('SustainityScoreCategory', () {
    expect(sustainityScoreBranchesInfos.length,
        api.SustainityScoreCategory.values.length);
  });
}
