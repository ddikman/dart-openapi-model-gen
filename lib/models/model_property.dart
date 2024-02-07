import 'package:dart_openapi_model_gen/models/type_category.dart';

class ModelProperty {
  String name;
  String type;
  bool isRequired;
  TypeCategory category;

  ModelProperty(
      {required this.name,
      required this.type,
      required this.isRequired,
      required this.category});

  bool get isOptional => !isRequired;

  bool get isList => type.startsWith('List<');

  bool get isSimpleType =>
      category == TypeCategory.simple || category == TypeCategory.simpleList;

  get isDependency => !isSimpleType;

  // If a list of models or a single model ref, will return the name, otherwise throw
  String getModelOrEnumName() {
    if (isSimpleType) {
      throw Exception('Property $name is not a model');
    }
    if (isList) {
      return type.substring(5, type.length - 1);
    }
    return type;
  }

  @override
  String toString() {
    return 'ModelProperty{name: $name, type: $type, isRequired: $isRequired, category: $category}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelProperty &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          isRequired == other.isRequired &&
          category == other.category;

  @override
  int get hashCode =>
      name.hashCode ^ type.hashCode ^ isRequired.hashCode ^ category.hashCode;
}
