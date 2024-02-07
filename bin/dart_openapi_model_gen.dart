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

  final models = SpecParser.parse(response.body);

  await ensureDirectoryExists(outputPath);

  var generatedModels = 0;
  for (var model in models) {
    if (includeModels.isNotEmpty && !includeModels.contains(model.modelName)) {
      continue;
    }

    final modelContents = ModelGenerator.generateModel(model);

    // Write the class content to a Dart file
    final fileName = '$outputPath/${model.filename()}';
    final file = File(fileName);
    await file.writeAsString(modelContents);
    print('Generated: $fileName');
    generatedModels++;
  }

  print("Done! Written $generatedModels models.");
}
