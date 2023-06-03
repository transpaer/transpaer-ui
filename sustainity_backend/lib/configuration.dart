import 'dart:io' as io;
import 'dart:convert' as convert;

import 'package:json_annotation/json_annotation.dart';

part 'configuration.g.dart';

@JsonSerializable()
class SecretConfig {
  @JsonKey(name: 'host')
  String host;

  @JsonKey(name: 'user')
  String user;

  @JsonKey(name: 'password')
  String password;

  SecretConfig(
      {required this.host, required this.user, required this.password});
  SecretConfig.debug() : this(host: 'localhost', user: '', password: '');

  factory SecretConfig.fromJson(Map<String, dynamic> json) =>
      _$SecretConfigFromJson(json);
  Map<String, dynamic> toJson() => _$SecretConfigToJson(this);
}

Future<SecretConfig> loadSecretConfigOrDefault() async {
  try {
    const path = '/etc/sustainify/secrets/sustainify.json';
    var file = io.File(path);
    if (file.existsSync()) {
      print("Loading config from a file");
      var contents = await io.File(path).readAsString();
      var json = convert.jsonDecode(contents);
      return SecretConfig.fromJson(json);
    }
  } catch (e) {
    print("Failed: $e");
  }

  try {
    const env = 'SUSTAINIFY_CONFIG';
    if (io.Platform.environment.containsKey(env)) {
      print("Loading config from env variable");
      var contents = io.Platform.environment[env];
      var json = convert.jsonDecode(contents!);
      return SecretConfig.fromJson(json);
    }
  } catch (e) {
    print("Failed: $e");
  }

  print("Using default config");
  return SecretConfig.debug();
}
