import 'dart:convert';

import 'package:dart_openapi_model_gen/models/enum_model.dart';
import 'package:dart_openapi_model_gen/models/model.dart';
import 'package:dart_openapi_model_gen/models/model_property.dart';
import 'package:dart_openapi_model_gen/models/type_category.dart';
import 'package:dart_openapi_model_gen/string_helpers.dart';

class SpecParser {
  List<EnumModel> enums = [];
  List<Model> models = [];

  List<Model> parse(String openApiSpecJson) {
    try {
      final data = json.decode(openApiSpecJson) as Map<String, dynamic>;
      models = _parseDefinitions(data['definitions'] as Map<String, dynamic>);
      return models;
    } catch (err, st) {
      throw Exception('Failed to parse OpenAPI spec: $err\n\n$st');
    }
  }

  List<Model> _parseDefinitions(Map<String, dynamic> definitions) {
    final models =
        definitions.entries.map((e) => _parseModel(e.key, e.value)).toList();

    return models.map((model) {
      final dependencies = model.properties
          .where((p) => p.isDependency)
          .map((p) => p.getModelOrEnumName())
          .toList();

      return model.copyWith(dependencies: dependencies);
    }).toList();
  }

  Model _parseModel(String modelName, Map<String, dynamic> modelDetails) {
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
    } catch (err, st) {
      throw Exception('Failed to parse model $modelName: $err\n\n$st');
    }
  }

  List<ModelProperty> _parseProperties(
      Map<String, dynamic> propertyDefinitions, Set requiredProperties) {
    final properties = <ModelProperty>[];

    propertyDefinitions.forEach((name, data) {
      try {
        final type = _parseType(data);
        properties.add(ModelProperty(
          name: name.toCamelCase(),
          originalName: name,
          type: type.name,
          category: type.category,
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

  _PropertyType _parseType(Map<String, dynamic> propertyData) {
    if (propertyData.containsKey('enum')) {
      return _parseEnumType(propertyData);
    }

    final type = (propertyData['type'] ?? propertyData['format']) as String?;
    if (type == null) {
      return _PropertyType(
          name: _getRef(propertyData['\$ref']).capitalize(),
          category: TypeCategory.model);
    }

    if (type == 'array') {
      final items = propertyData['items'] as Map<String, dynamic>;
      final listType = _parseType(items);
      final isSimple = listType.category == TypeCategory.simple;
      return _PropertyType(
          name: 'List<${listType.name}>',
          category:
              isSimple ? TypeCategory.simpleList : TypeCategory.complexList);
    }

    return _PropertyType(
        name: _getDartType(type), category: TypeCategory.simple);
  }

  _PropertyType _parseEnumType(Map<String, dynamic> propertyData) {
    final format = propertyData['format'] as String?;
    if (format == null) {
      // We have no name of a model to create, so we just return the type
      return _PropertyType(name: 'String', category: TypeCategory.simple);
    }

    final name = (propertyData['format'] as String)
        .split('.')
        .last
        .toCamelCase()
        .capitalize();

    final type = propertyData['type'];
    final values = (propertyData['enum'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    enums.add(EnumModel(name: name, values: values, type: type));
    return _PropertyType(name: name, category: TypeCategory.enumeration);
  }
}

class _PropertyType {
  final String name;
  final TypeCategory category;

  _PropertyType({required this.name, required this.category});
}
