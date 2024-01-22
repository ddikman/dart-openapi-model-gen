import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<void> ensureDirectoryExists(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
}

Future<dynamic> downloadAndParseJson(String inputUrl) async {
  var response = await http.get(Uri.parse(inputUrl));

  if (response.statusCode == 200) {
    var jsonData = json.decode(response.body);
    // Process jsonData here
    return jsonData;
  } else {
    throw Exception(
        'Failed to download JSON. Status Code: ${response.statusCode}');
  }
}

String toSnakeCase(String str) {
  return str.replaceAllMapped(RegExp(r'[A-Z]'), (Match match) {
    return '_${match[0]!.toLowerCase()}';
  }).replaceFirst(RegExp(r'^_'), '');
}

String mapSwaggerTypeToDartType(String swaggerType) {
  switch (swaggerType) {
    case 'string':
      return 'String';
    case 'integer':
      return 'int';
    case 'boolean':
      return 'bool';
    case 'array':
      return 'List'; // You might need to handle the items of the array
    default:
      return 'dynamic'; // Fallback type
  }
}

String? getRef(String? ref) {
  if (ref == null) {
    return null;
  }

  final parts = ref.split('/');
  return parts[parts.length - 1];
}

(String, bool) getPropertyType(dynamic propertyDetails) {
  final ref = getRef(propertyDetails['\$ref']);
  if (ref != null) {
    return (ref, true);
  }
  if (propertyDetails['format'] == 'json') {
    return ('dynamic', false);
  }
  final swaggerType = propertyDetails['type'] as String;
  return (mapSwaggerTypeToDartType(swaggerType), false);
}

String generateDartClass(String modelName, Map<String, dynamic> properties) {
  var classBuffer = StringBuffer();

  classBuffer.writeln('class $modelName {');

  final dependencies = <String>{};
  properties.forEach((propertyName, propertyDetails) {
    try {
      final (type, isDependency) = getPropertyType(propertyDetails);
      if (isDependency) {
        dependencies.add(type);
      }
      classBuffer.writeln('  final $type $propertyName;');
    } catch (e, st) {
      print(st);
      throw Exception("Failed to parse property $propertyName: $e");
    }
  });

  // Constructor with named parameters and default values
  classBuffer.write('  $modelName({');
  properties.keys.forEach((propertyName) {
    classBuffer
        .write('required this.$propertyName, '); // Add default values if needed
  });
  classBuffer.writeln('});');

  // copyWith method
  classBuffer.writeln('  $modelName copyWith({');
  properties.forEach((propertyName, _) {
    final (dartType, _) = getPropertyType(properties[propertyName]);
    classBuffer.writeln('    $dartType? $propertyName,');
  });

  classBuffer.write('  }) => $modelName(');
  properties.keys.forEach((propertyName) {
    classBuffer.write('$propertyName: $propertyName ?? this.$propertyName, ');
  });
  classBuffer.writeln(');');

  // Close class
  classBuffer.writeln('}');

  // Add dependencies
  final importStatements = dependencies
      .map((modelName) => 'import \'./$modelName.dart\';')
      .join('\n');

  return '$importStatements\n$classBuffer';
}

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption('input',
      abbr: 'i',
      help: 'URL of the Swagger/OpenAPI schema',
      mandatory: true,
      valueHelp: 'url');

  var results = parser.parse(arguments);
  var inputUrl = results['input'];

  if (inputUrl == null) {
    print('Please provide a URL with -i option.');
    return;
  }

  // Your logic to handle the input URL goes here
  print('Swagger/OpenAPI URL: $inputUrl');

  final data = await downloadAndParseJson(inputUrl);
  final models = data['definitions'] as Map<String, dynamic>;

  // Ensure the directory exists
  await ensureDirectoryExists('lib/gen');

  for (var modelName in models.keys) {
    final model = models[modelName];
    final properties = model['properties'] as Map<String, dynamic>;
    final classContent = generateDartClass(modelName, properties);

    // Write the class content to a Dart file
    final fileName = 'lib/gen/${toSnakeCase(modelName)}.dart';
    final file = File(fileName);
    await file.writeAsString(classContent);
    print('Generated: $fileName');
  }

  print("Done! Generated ${models.length} models.");
}
