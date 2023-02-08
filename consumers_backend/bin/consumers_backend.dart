import 'dart:io' as io;

import 'package:arango_driver/arango_driver.dart' as arango;
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:consumers_backend/consumers_backend.dart' as consumers_backend;

void main(List<String> args) async {
  final port = 8080;
  final ip = io.InternetAddress.anyIPv4;

  final client = arango.ArangoDBClient(
      scheme: 'http',
      host: 'localhost',
      port: 8529,
      db: '_system',
      user: '',
      pass: '');

  final router = shelf_router.Router()
    ..get('/products/<id>', consumers_backend.ProductHandler(client))
    ..get('/products/<id>/alternatives',
        consumers_backend.AlternativesHandler(client))
    ..get(
        '/manufacturers/<id>', consumers_backend.ManufacturersHandler(client));

  final handler =
      shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(router);
  final server = await shelf_io.serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
