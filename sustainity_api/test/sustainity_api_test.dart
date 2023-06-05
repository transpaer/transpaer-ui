import 'dart:convert';
import 'package:sustainity_api/sustainity_api.dart';
import 'package:test/test.dart';

void main() {
  test('Serde Topic', () {
    expect(InfoTopic.main, InfoTopicExtension.fromString('info--main'));
    expect(InfoTopic.bcorp, InfoTopicExtension.fromString('badge--bcorp'));
    expect(InfoTopic.tco, InfoTopicExtension.fromString('badge--tco'));
    expect(InfoTopic.fti, InfoTopicExtension.fromString('badge--fti'));
    expect(InfoTopic.main, InfoTopicExtension.fromString('wrong value'));
  });

  test('Serde Product', () {
    final originalString =
        '{"product_id":"P","name":"N","description":"D","badges":["bcorp","tco"],"scores":{"fti":25}}';
    final originalItem = ProductShort(
      productId: "P",
      name: "N",
      description: "D",
      badges: <BadgeName>[BadgeName.bcorp, BadgeName.tco],
      scores: {ScorerName.fti: 25},
    );

    final resultString = jsonEncode(originalItem);
    final resultItem = ProductShort.fromJson(jsonDecode(originalString));

    expect(resultString, originalString);
    expect(resultItem.productId, originalItem.productId);
    expect(resultItem.name, originalItem.name);
    expect(resultItem.description, originalItem.description);
    expect(resultItem.badges, originalItem.badges);
    expect(resultItem.scores, originalItem.scores);
  });

  test('Serde Organisation', () {
    final originalString =
        '{"organisation_id":"O","name":"N","description":"D","badges":["bcorp","tco"],"scores":{"fti":25}}';
    final originalItem = Organisation(
      organisationId: "O",
      name: "N",
      description: "D",
      badges: <BadgeName>[BadgeName.bcorp, BadgeName.tco],
      scores: {ScorerName.fti: 25},
    );

    final resultString = jsonEncode(originalItem);
    final resultItem = Organisation.fromJson(jsonDecode(originalString));

    expect(resultString, originalString);
    expect(resultItem.organisationId, originalItem.organisationId);
    expect(resultItem.name, originalItem.name);
    expect(resultItem.description, originalItem.description);
    expect(resultItem.badges, originalItem.badges);
    expect(resultItem.scores, originalItem.scores);
  });
}
