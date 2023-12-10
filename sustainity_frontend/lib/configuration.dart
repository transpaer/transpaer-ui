import 'package:flutter/foundation.dart';

class Config {
  String backendScheme;
  String backendHost;
  int backendPort;

  Config({
    required this.backendScheme,
    required this.backendHost,
    required this.backendPort,
  });
  Config.debug()
      : this(
          backendScheme: 'http',
          backendHost: 'localhost',
          backendPort: 8080,
        );
  Config.release()
      : this(
          backendScheme: 'https',
          backendHost: 'api.sustainity.dev',
          backendPort: 443,
        );

  static Config load() {
    if (kReleaseMode) {
      return Config.release();
    } else {
      return Config.debug();
    }
  }
}
