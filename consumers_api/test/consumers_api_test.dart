import 'dart:convert';
import 'package:consumers_api/consumers_api.dart';
import 'package:test/test.dart';

void main() {
  test('Serialize Product', () {
    final item = ProductShort(
      productId: "P",
      name: "N",
      description: "D",
      badges: <String>["B1", "B2"],
    );
    final result = jsonEncode(item);
    expect(result,
        '{"product_id":"P","name":"N","description":"D","badges":["B1","B2"]}');
  });

  test('Serialize Manufacturer', () {
    final item = Manufacturer(
      manufacturerId: "M",
      name: "N",
      description: "D",
      badges: <String>["B1", "B2"],
    );
    final result = jsonEncode(item);
    expect(result,
        '{"manufacturer_id":"M","name":"N","description":"D","badges":["B1","B2"]}');
  });
}
