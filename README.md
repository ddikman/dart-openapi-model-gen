# dart-openapi-model-gen

CLI to generate Dart models of OpenAPI Swagger definitions. It was specifically built to support Supabase generation as the Supabase CLI is lacking these at the moment.

These models can then be used in your project to do type-safe queries to the database.

## Use in your repository

```shell
flutter pub add --dev dart_openapi_model_gen
dart run dart_openapi_model_gen -o lib/models/gen -i <your-swagger-url>
```

## Example

You can run this to try it on any swagger file.

```shell
dart run bin/main.dart -o lib/models/gen -i https://petstore.swagger.io/v2/swagger.json
```

For Supabase specifically, you would use this:

```
dart run bin/main.dart -i https://<your-project-id>.supabase.co/rest/v1/?apikey=<your-anon-key>
```