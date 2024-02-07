import 'package:dart_openapi_model_gen/models/model_property.dart';
import 'package:dart_openapi_model_gen/string_helpers.dart';

class Model {
  String modelName;
  List<ModelProperty> properties;
  List<String> dependencies = [];

  Model(
      {required this.modelName,
      required this.properties,
      required this.dependencies});

  String className() {
    return modelName.capitalize().toCamelCase();
  }

  String filename() {
    return '${modelName.toSnakeCase()}.dart';
  }

  Model copyWith(
      {String? modelName,
      List<ModelProperty>? properties,
      List<String>? dependencies}) {
    return Model(
      modelName: modelName ?? this.modelName,
      properties: properties ?? this.properties,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  @override
  String toString() {
    return 'Model{modelName: $modelName, properties: $properties, dependencies: $dependencies}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model &&
          runtimeType == other.runtimeType &&
          modelName == other.modelName &&
          properties == other.properties &&
          dependencies == other.dependencies;

  @override
  int get hashCode =>
      modelName.hashCode ^ properties.hashCode ^ dependencies.hashCode;
}
