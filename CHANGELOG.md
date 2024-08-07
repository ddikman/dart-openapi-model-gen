## 0.1.7

* Fixed bug introduced from 0.1.6 where optional lists got double periods
* Fixed linting issues around dynamics
* Added some tests to avoid future misses
* Added CI for tests to run

## 0.1.6

* Fixed bug in casting arrays of values such as `.cast<String>` which was missing a period

## 0.1.5

* Generation syntax fix

## 0.1.4

* Fixed generation of lists where a cast from `List<dynamic>` had to happen

## 0.1.3

* Fixed generation problem causing syntax error for optional doubles

## 0.1.2

* Fixed problem with deserializing doubles

## 0.1.1

* Added support for Supabase's `jsonb` format, same as json

## 0.1.0

* Added serialization to and from snake case whilst generating camel case property names

Before:
```dart
// This file was generated by dart_openapi_model_gen
class AdminUser {
  ...
  final String id;
  final String? added_by;
  final String created_at;
  ...
  Map<String, dynamic> toJson() => {
        'id': id,
        'added_by': added_by,
        'created_at': created_at,
  };

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        added_by: json['added_by'] as String?,
        created_at: json['created_at'] as String,
  );
}

```

After:
```dart
// This file was generated by dart_openapi_model_gen
class AdminUser {
  ...
  final String id;
  final String? addedBy;
  final String createdAt;
  ...
  Map<String, dynamic> toJson() => {
        'id': id,
        'added_by': addedBy,
        'created_at': createdAt,
  };

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        addedBy: json['added_by'] as String?,
        createdAt: json['created_at'] as String,
  );
}
```

## 0.0.16

* Issue with generating enums

## 0.0.15

* Fixed json parsing and encoding of enums

## 0.0.14

* Reverted fix for spaced enums as dart doesn't allow values for enums

## 0.0.13

* Fixed issue with enum values containing spaces

## 0.0.12

* Added support for generating enumerations
* Will automatically generate any dependencies for selected models
* Added some tests

## 0.0.11

* Refactored parser and generator to allow adding enum support more easily
* Improved output formatting

## 0.0.10

* Added capitalization and camel case to model names

## 0.0.9

* Fixed bug with new output model filter

## 0.0.8

* Fixed bug where required properties were optional
* Prettified output a little and added a table/type name

## 0.0.7

* Added an output filter of selected models to generate

## 0.0.6

* Added support for optional types

## 0.0.5

* Added fromJson and toJson methods
* Added outputDir parameter

## 0.0.4

* Fixed script startup path
* Added run instructions for other repos

## 0.0.3

* Added BSD license

## 0.0.2

* Renamed everything to make it more generic than just targetting Supabase.

## 0.0.1

* First version, able to do a parse of the public Swagger API definition example.
