import 'dart:convert';
import 'package:consumers_api/consumers_api.dart';
import 'package:test/test.dart';

void main() {
  test('Serialize Product', () {
    final item = Product(product_id: "P", name: "N", manufacturer_id: "M");
    final result = jsonEncode(item);
    expect(result, '{"product_id":"P","name":"N","manufacturer_id":"M"}');
  });

  test('Serialize Manufacturer', () {
    final item = Manufacturer(manufacturer_id: "M", name: "N");
    final result = jsonEncode(item);
    expect(result, '{"manufacturer_id":"M","name":"N"}');
  });
}
