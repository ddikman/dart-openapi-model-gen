import 'package:dart_openapi_model_gen/models/model_property.dart';
import 'package:dart_openapi_model_gen/models/type_category.dart';
import 'package:dart_openapi_model_gen/services/model_generator.dart';
import 'package:test/test.dart';

void main() {
  final requiredProperty = ModelProperty(
    originalName: 'model_property',
    name: 'modelProperty',
    type: 'dynamic',
    isRequired: true,
    category: TypeCategory.simple,
  );

  final optionalProperty = requiredProperty.optional;

  test('can generate optional array', () {
    final result = ModelGenerator.propertyFromJson(
        optionalProperty.withType('List<String>', TypeCategory.simpleList));
    expect(result, 'json[\'model_property\']?.cast<String>()');
  });

  test('can generate array', () {
    final result = ModelGenerator.propertyFromJson(
        requiredProperty.withType('List<String>', TypeCategory.simpleList));
    expect(result, 'json[\'model_property\'].cast<String>()');
  });

  test('can generate dynamic', () {
    final result =
        ModelGenerator.propertyFromJson(requiredProperty.withType('dynamic'));
    expect(result, 'json[\'model_property\'] as dynamic');
  });

  test('can generate optional dynamic', () {
    final result =
        ModelGenerator.propertyFromJson(optionalProperty.withType('dynamic'));
    expect(result, 'json[\'model_property\'] as dynamic');
  });

  test('can generate enum', () {
    final result = ModelGenerator.propertyFromJson(
        requiredProperty.withType('EnumType', TypeCategory.enumeration));
    expect(result,
        'EnumType.values.where((e) => e.name == json[\'model_property\']).first');
  });

  test('can generate optional enum', () {
    final result = ModelGenerator.propertyFromJson(
        optionalProperty.withType('EnumType', TypeCategory.enumeration));
    expect(result,
        'EnumType.values.where((e) => e.name == json[\'model_property\']).firstOrNull');
  });
}

extension PropertyBuilder on ModelProperty {
  ModelProperty get optional => ModelProperty(
        originalName: originalName,
        name: name,
        type: type,
        isRequired: false,
        category: category,
      );

  ModelProperty get required => ModelProperty(
        originalName: originalName,
        name: name,
        type: type,
        isRequired: true,
        category: category,
      );

  ModelProperty withType(String type,
          [TypeCategory category = TypeCategory.simple]) =>
      ModelProperty(
        originalName: originalName,
        name: name,
        type: type,
        isRequired: isRequired,
        category: category,
      );
}
