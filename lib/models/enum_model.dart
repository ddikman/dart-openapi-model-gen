import 'package:dart_openapi_model_gen/string_helpers.dart';

class EnumModel {
  final String name;
  final List<String> values;
  final String type;

  EnumModel({required this.name, required this.values, required this.type});

  String get filename => "${name.toSnakeCase()}.dart";
}
