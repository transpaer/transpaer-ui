// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

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
          backendHost: 'api.transpaer.app',
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
