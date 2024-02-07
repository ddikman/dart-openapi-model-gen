import 'dart:convert';

import 'package:dart_openapi_model_gen/models/model.dart';
import 'package:dart_openapi_model_gen/models/model_property.dart';
import 'package:dart_openapi_model_gen/string_helpers.dart';

class SpecParser {
  static List<Model> parse(String openApiSpecJson) {
    try {
      final data = json.decode(openApiSpecJson) as Map<String, dynamic>;
      return _parseDefinitions(data['definitions'] as Map<String, dynamic>);
    } catch (err) {
      throw Exception('Failed to parse OpenAPI spec: $err');
    }
  }

  static List<Model> _parseDefinitions(Map<String, dynamic> definitions) {
    final models =
        definitions.entries.map((e) => _parseModel(e.key, e.value)).toList();

    return models.map((model) {
      final dependencies = model.properties
          .where((p) => p.isModel)
          .map((p) => models.singleWhere((m) => m.modelName == p.getModelType(),
              orElse: () => throw Exception(
                  'Failed to find dependency for property ${p.name} (${p.type}) in model ${model.modelName}')))
          .toList();

      return model.copyWith(dependencies: dependencies);
    }).toList();
  }

  static Model _parseModel(
      String modelName, Map<String, dynamic> modelDetails) {
    try {
      final properties = modelDetails['properties'] as Map<String, dynamic>;
      final requiredProperties =
          (modelDetails['required'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toSet();

      return Model(
        modelName: modelName,
        properties: _parseProperties(properties, requiredProperties),
        dependencies: [],
      );
    } catch (err) {
      throw Exception('Failed to parse model $modelName: $err');
    }
  }

  static List<ModelProperty> _parseProperties(
      Map<String, dynamic> propertyDefinitions, Set requiredProperties) {
    final properties = <ModelProperty>[];

    propertyDefinitions.forEach((name, data) {
      try {
        final type = _getType(data);
        properties.add(ModelProperty(
          name: name,
          type: type.name,
          comment: type.comment,
          isModel: type.isModel,
          isRequired: requiredProperties.contains(name),
        ));
      } catch (err, st) {
        print(err);
        print(st);
        throw Exception('Failed to parse property $name');
      }
    });

    return properties;
  }

  static String _getDartType(String openApiType) {
    switch (openApiType) {
      case 'string':
        return 'String';
      case 'integer':
        return 'int';
      case 'boolean':
        return 'bool';
      case 'array':
        return 'List'; // You might need to handle the items of the array
      case 'json':
        return 'dynamic';
      case 'number':
        return 'double';
      default:
        throw Exception('Unsupported type: $openApiType');
    }
  }

  static String _getRef(String ref) {
    return ref.split('/').last;
  }

  static _PropertyType _getType(Map<String, dynamic> propertyData) {
    // generate this as a type
    final enumValues = propertyData['enum'] as List<dynamic>?;
    final comment = enumValues != null ? 'enum: ${enumValues.join(', ')}' : '';

    final type = (propertyData['type'] ?? propertyData['format']) as String?;
    if (type == null) {
      return _PropertyType(
          name: _getRef(propertyData['\$ref']).capitalize(),
          isModel: true,
          comment: comment);
    }

    if (type == 'array') {
      final items = propertyData['items'] as Map<String, dynamic>;
      final listType = _getType(items);
      return _PropertyType(
          name: 'List<${listType.name}>',
          isModel: listType.isModel,
          comment: comment);
    }

    return _PropertyType(
        name: _getDartType(type), isModel: false, comment: comment);
  }
}

class _PropertyType {
  final String name;
  final bool isModel;
  final String comment;

  _PropertyType(
      {required this.name, required this.isModel, required this.comment});
}
