extension StringHelpers on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toCamelCase() {
    return replaceAllMapped(RegExp(r'_(\w)'), (Match match) {
      return match[1]!.toUpperCase();
    });
  }

  String toSnakeCase() {
    return replaceAllMapped(RegExp(r'[A-Z]'), (Match match) {
      return '_${match[0]!.toLowerCase()}';
    }).replaceFirst(RegExp(r'^_'), '');
  }
}
