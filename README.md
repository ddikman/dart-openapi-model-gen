# Supabase Model Generator

Command line tool for generator models of a Supabase Swagger API definition.

These models can then be used in your project to do type-safe queries to the database.

## Example

You can run this to try it on any swagger file.

```shell
dart run bin/supabase_model_generator.dart -i https://petstore.swagger.io/v2/swagger.json
```

For Supabase specifically, you would use this:

```
dart run bin/supabase_model_generator.dart -i https://<your-project-id>.supabase.co/rest/v1/?apikey=<your-anon-key>
```