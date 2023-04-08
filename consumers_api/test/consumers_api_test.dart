import 'dart:convert';
import 'package:consumers_api/consumers_api.dart';
import 'package:test/test.dart';

void main() {
  test('Serde Product', () {
    final originalString =
        '{"product_id":"P","name":"N","description":"D","badges":["bcorp","tco"]}';
    final originalItem = ProductShort(
      productId: "P",
      name: "N",
      description: "D",
      badges: <BadgeName>[BadgeName.bcorp, BadgeName.tco],
    );

    final resultString = jsonEncode(originalItem);
    final resultItem = ProductShort.fromJson(jsonDecode(originalString));

    expect(resultString, originalString);
    expect(resultItem.productId, originalItem.productId);
    expect(resultItem.name, originalItem.name);
    expect(resultItem.description, originalItem.description);
    expect(resultItem.badges, originalItem.badges);
  });

  test('Serde Manufacturer', () {
    final originalString =
        '{"manufacturer_id":"M","name":"N","description":"D","badges":["bcorp","tco"]}';
    final originalItem = Manufacturer(
      manufacturerId: "M",
      name: "N",
      description: "D",
      badges: <BadgeName>[BadgeName.bcorp, BadgeName.tco],
    );

    final resultString = jsonEncode(originalItem);
    final resultItem = Manufacturer.fromJson(jsonDecode(originalString));

    expect(resultString, originalString);
    expect(resultItem.manufacturerId, originalItem.manufacturerId);
    expect(resultItem.name, originalItem.name);
    expect(resultItem.description, originalItem.description);
    expect(resultItem.badges, originalItem.badges);
  });
}
