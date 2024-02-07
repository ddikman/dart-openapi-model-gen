import 'package:args/args.dart';
import 'package:dart_openapi_model_gen/services/model_generator.dart';
import 'package:dart_openapi_model_gen/services/spec_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> ensureDirectoryExists(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    await directory.create(recursive: true);
  }
}

Future<void> writeFile(String path, String contents) async {
  final file = File(path);
  await file.writeAsString(contents);
  print('Generated: $path');
}

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption('input',
      abbr: 'i',
      help: 'URL of the Swagger/OpenAPI schema',
      mandatory: true,
      valueHelp: 'url');

  parser.addOption('output',
      abbr: 'o',
      help: 'Folder to write the generated files to',
      valueHelp: 'directory path');

  parser.addOption('models',
      abbr: 'm',
      help: 'Comma separated list of models to generate',
      valueHelp: 'model1,model2');

  var results = parser.parse(arguments);
  var inputUrl = results['input'];
  var includeModels = (results['models'] as String? ?? '')
      .split(',')
      .map((e) => e.trim())
      .where((element) => element.isNotEmpty)
      .toList();

  var outputPath = results['output'] ?? 'lib/gen';

  if (inputUrl == null) {
    print('Please provide a URL with -i option.');
    return;
  }

  print('Swagger/OpenAPI URL: $inputUrl');

  var response = await http.get(Uri.parse(inputUrl));
  if (response.statusCode != 200) {
    throw Exception(
        'Failed to download JSON. Status Code: ${response.statusCode}');
  }

  final specParser = SpecParser();
  specParser.parse(response.body);

  await ensureDirectoryExists(outputPath);

  final generated = <String>[];
  for (var model in specParser.models) {
    if (includeModels.isNotEmpty && !includeModels.contains(model.modelName)) {
      continue;
    }

    final modelContents = ModelGenerator.generateModel(model);
    await writeFile("$outputPath/${model.filename()}", modelContents);
    generated.add(model.modelName);
  }
  print("Written ${generated.length} models.");

  final dependencies = specParser.models
      .expand((model) => model.dependencies)
      .where((element) => !generated.contains(element))
      .toSet();

  var generatedDependencies = 0;
  for (var dependency in dependencies) {
    final model = specParser.models
        .where((element) => element.modelName == dependency)
        .firstOrNull;
    if (model != null) {
      final modelContents = ModelGenerator.generateModel(model);
      await writeFile("$outputPath/${model.filename()}", modelContents);
      continue;
    }

    final enumeration = specParser.enums
        .where((element) => element.name == dependency)
        .firstOrNull;
    if (enumeration != null) {
      final enumerationContents = ModelGenerator.generateEnum(enumeration);
      await writeFile(
          "$outputPath/${enumeration.filename}", enumerationContents);
      generatedDependencies++;
      continue;
    }

    throw Exception('Dependency not found: $dependency');
  }
  if (generatedDependencies > 0) {
    print("Written $generatedDependencies required dependencies.");
  }

  print('Done.');
}
