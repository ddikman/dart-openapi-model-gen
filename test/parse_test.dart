import 'package:dart_openapi_model_gen/services/spec_parser.dart';
import 'package:test/test.dart';

void main() {
  test('can parse a simple list', () {
    const input = '''{
  "definitions": {
    "myModel": {
      "properties": {
          "myList": {
          "type": "array",
          "items": {"type": "string"}
        }
      }
    }
  }
}''';

    final specParser = SpecParser();
    final result = specParser.parse(input);
    final model = result.single;
    expect(model.modelName, 'myModel');
    expect(model.className(), 'MyModel');
    expect(model.filename(), 'my_model.dart');
    expect(model.properties.length, 1);
    expect(model.properties.single.name, 'myList');
    expect(model.properties.single.type, 'List<String>');
    expect(model.dependencies.isEmpty, true);
  });

  test('can parse a list of enums', () {
    const input = '''{
  "definitions": {
    "myModel": {
      "properties": {
          "myList": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["a", "b", "c"],
            "format": "myEnum"
          }
        }
      }
    }
  }
}''';

    final specParser = SpecParser();
    final result = specParser.parse(input);
    final model = result.single;
    expect(model.modelName, 'myModel');
    expect(model.className(), 'MyModel');
    expect(model.filename(), 'my_model.dart');
    expect(model.properties.length, 1);
    expect(model.properties.single.name, 'myList');
    expect(model.properties.single.type, 'List<MyEnum>');
    expect(model.dependencies.first, "MyEnum");
  });

  test('can parse enums with spaces', () {
    const input = '''{
  "definitions": {
    "myModel": {
      "properties": {
          "myEnum": {
          "type": "string",
          "enum": ["Value A", "Value B"],
          "format": "myEnumType"
        }
      }
    }
  }
}''';

    final specParser = SpecParser()..parse(input);

    final enumeration =
        specParser.enums.singleWhere((e) => e.name == 'MyEnumType');
    expect(enumeration.values.length, 2);
    expect(enumeration.values, ['Value A', 'Value B']);
  });
}
