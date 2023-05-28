import 'dart:io' as io;
import 'dart:convert' as convert;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;

import 'package:consumers_backend/configuration.dart';
import 'package:consumers_backend/db_client.dart';
import 'package:consumers_backend/handlers.dart';

void main(List<String> args) async {
  final port = 8080;
  final ip = io.InternetAddress.anyIPv4;

  final secret = await loadSecretConfigOrDefault();

  final client =
      DbClient(host: secret.host, user: secret.user, password: secret.password);
  final encoder = convert.JsonEncoder.withIndent('  ');

  final router = shelf_router.Router()
    ..get('/', HealthCheckHandler())
    ..get('/search/products', ProductSearchHandler(client, encoder))
    ..get('/search/organisations', OrganisationSearchHandler(client, encoder))
    ..get('/info/<id>', InfoHandler(client, encoder))
    ..get('/organisation/<id>', OrganisationHandler(client, encoder))
    ..get('/product/<id>', ProductHandler(client, encoder))
    ..get('/product/<id>/alternatives', AlternativesHandler(client, encoder));

  final handler =
      shelf.Pipeline().addMiddleware(shelf.logRequests()).addHandler(router);

  final server = await shelf_io.serve(handler, ip, port);

  print('Server listening on port ${server.port}');
}
