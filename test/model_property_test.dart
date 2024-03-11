import 'package:dart_openapi_model_gen/models/model_property.dart';
import 'package:dart_openapi_model_gen/models/type_category.dart';
import 'package:test/test.dart';

void main() {
  test('a simple list is not a dependency', () {
    final property = ModelProperty(
      name: 'myList',
      originalName: 'my_list',
      type: 'List<String>',
      isRequired: true,
      category: TypeCategory.simpleList,
    );

    expect(property.isDependency, false);
  });

  test('a list of models or enums is a dependency', () {
    final property = ModelProperty(
      name: 'myList',
      originalName: 'my_list',
      type: 'List<MyEnum>',
      isRequired: true,
      category: TypeCategory.complexList,
    );

    expect(property.isDependency, true);
  });
}
