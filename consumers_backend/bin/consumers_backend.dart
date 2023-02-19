import 'dart:io' as io;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:consumers_backend/db_client.dart';
import 'package:consumers_backend/handlers.dart';

void main(List<String> args) async {
  final port = 8080;
  final ip = io.InternetAddress.anyIPv4;

  final client = DbClient();

  final router = shelf_router.Router()
    ..get('/search', SearchHandler(client))
    ..get('/products/<id>', ProductHandler(client))
    ..get('/products/<id>/alternatives', AlternativesHandler(client))
    ..get('/manufacturers/<id>', ManufacturersHandler(client));

  final handler =
      shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(router);

  final server = await shelf_io.serve(handler, ip, port);

  print('Server listening on port ${server.port}');
}
