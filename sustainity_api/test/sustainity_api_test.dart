import 'dart:convert';
import 'package:sustainity_api/sustainity_api.dart';
import 'package:test/test.dart';

void main() {
  test('Serde Topic', () {
    expect(LibraryTopic.main, LibraryTopicExtension.fromString('cert:main'));
    expect(LibraryTopic.bcorp, LibraryTopicExtension.fromString('cert:bcorp'));
    expect(LibraryTopic.tco, LibraryTopicExtension.fromString('cert:tco'));
    expect(LibraryTopic.fti, LibraryTopicExtension.fromString('cert:fti'));
    expect(LibraryTopic.main, LibraryTopicExtension.fromString('wrong value'));
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
        '{"organisation_id":"O","name":"N","description":"D","images":[{"image":"I","source":"wikidata"}],"websites":["www.example.com"],"badges":["bcorp","tco"],"scores":{"fti":25}}';
    final originalItem = Organisation(
      organisationId: "O",
      name: "N",
      description: "D",
      images: [Image(image: "I", source: Source.wikidata)],
      websites: ["www.example.com"],
      badges: [BadgeName.bcorp, BadgeName.tco],
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
