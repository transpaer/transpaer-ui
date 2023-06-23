import 'dart:convert';
import 'package:collection/collection.dart';
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
    final Function deepEq = const DeepCollectionEquality().equals;
    final originalString = '{'
        '"product_id":"P",'
        '"gtins":["12345","67890"],'
        '"names":[{"text":"N","source":"wiki"}],'
        '"descriptions":[{"text":"D","source":"eu"}],'
        '"images":[{"image":"I","source":"eu"}],'
        '"manufacturers":['
        '{"organisation_id":"O","name":"N","description":"D","badges":["eu","tco"],"scores":{"fti":26}}'
        '],'
        '"alternatives":[{'
        '"category":"C",'
        '"alternatives":['
        '{"product_id":"P","name":"N","description":"D","badges":["eu","tco"],"scores":{"fti":25}}'
        ']'
        '}],'
        '"badges":["bcorp","tco"],'
        '"scores":{"fti":25}'
        '}';
    final originalItem = ProductFull(
      productId: "P",
      gtins: ["12345", "67890"],
      names: [Text(text: "N", source: Source.wikidata)],
      descriptions: [Text(text: "D", source: Source.euEcolabel)],
      images: [Image(image: "I", source: Source.euEcolabel)],
      manufacturers: [
        OrganisationShort(
          organisationId: "O",
          name: "N",
          description: "D",
          badges: <BadgeName>[
            BadgeName.euEcolabel,
            BadgeName.tco,
          ],
          scores: {ScorerName.fti: 26},
        )
      ],
      alternatives: [
        CategoryAlternatives(
          category: "C",
          alternatives: [
            ProductShort(
              productId: "P",
              name: "N",
              description: "D",
              badges: <BadgeName>[
                BadgeName.euEcolabel,
                BadgeName.tco,
              ],
              scores: {ScorerName.fti: 25},
            )
          ],
        )
      ],
      badges: <BadgeName>[BadgeName.bcorp, BadgeName.tco],
      scores: {ScorerName.fti: 25},
    );

    final resultString = jsonEncode(originalItem);
    final resultItem = ProductFull.fromJson(jsonDecode(originalString));

    expect(resultString, originalString);
    expect(resultItem.productId, originalItem.productId);
    expect(resultItem.names, originalItem.names);
    expect(resultItem.descriptions, originalItem.descriptions);
    expect(deepEq(resultItem.alternatives, originalItem.alternatives), true);
    expect(resultItem.badges, originalItem.badges);
    expect(resultItem.scores, originalItem.scores);
  });

  test('Serde Organisation', () {
    final originalString = '{'
        '"organisation_id":"O",'
        '"names":[{"text":"N","source":"wiki"}],'
        '"descriptions":[{"text":"D","source":"off"}],'
        '"images":[{"image":"I","source":"eu"}],'
        '"websites":["www.example.com"],'
        '"products":['
        '{"product_id":"P","name":"N","description":"D","badges":["eu","tco"],"scores":{"fti":25}}'
        '],'
        '"badges":["bcorp","tco"],'
        '"scores":{"fti":25}'
        '}';
    final originalItem = OrganisationFull(
      organisationId: "O",
      names: [Text(text: "N", source: Source.wikidata)],
      descriptions: [Text(text: "D", source: Source.openFoodFacts)],
      images: [Image(image: "I", source: Source.euEcolabel)],
      websites: ["www.example.com"],
      products: [
        ProductShort(
          productId: "P",
          name: "N",
          description: "D",
          badges: <BadgeName>[
            BadgeName.euEcolabel,
            BadgeName.tco,
          ],
          scores: {ScorerName.fti: 25},
        )
      ],
      badges: [BadgeName.bcorp, BadgeName.tco],
      scores: {ScorerName.fti: 25},
    );

    final resultString = jsonEncode(originalItem);
    final resultItem = OrganisationFull.fromJson(jsonDecode(originalString));

    expect(resultString, originalString);
    expect(resultItem.organisationId, originalItem.organisationId);
    expect(resultItem.names.length, originalItem.names.length);
    expect(resultItem.names[0], originalItem.names[0]);
    expect(resultItem.names, originalItem.names);
    expect(resultItem.descriptions, originalItem.descriptions);
    expect(resultItem.images, originalItem.images);
    expect(resultItem.websites, originalItem.websites);
    expect(resultItem.badges, originalItem.badges);
    expect(resultItem.scores, originalItem.scores);
  });
}
