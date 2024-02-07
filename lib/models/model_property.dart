class ModelProperty {
  String name;
  String type;
  bool isRequired;
  bool isModel;
  String comment;

  ModelProperty(
      {required this.name,
      required this.type,
      required this.isRequired,
      required this.comment,
      this.isModel = false});

  bool get isOptional => !isRequired;

  bool get isList => type.startsWith('List<');

  // If a list of models or a single model ref, will return the name, otherwise throw
  String getModelType() {
    if (!isModel) {
      throw Exception('Property $name is not a model');
    }
    if (isList) {
      return type.substring(5, type.length - 1);
    }
    return type;
  }

  @override
  String toString() {
    return 'ModelProperty{name: $name, type: $type, isRequired: $isRequired, isModel: $isModel}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelProperty &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          isRequired == other.isRequired &&
          isModel == other.isModel;

  @override
  int get hashCode =>
      name.hashCode ^ type.hashCode ^ isRequired.hashCode ^ isModel.hashCode;
}
