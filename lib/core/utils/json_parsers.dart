int parseIntSafe(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double parseDoubleSafe(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double? parseDoubleNullable(dynamic value) {
  if (value == null) return null;
  return parseDoubleSafe(value);
}

bool parseBoolSafe(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) {
    final v = value.toLowerCase().trim();
    return v == '1' || v == 'true' || v == 'yes';
  }
  return false;
}
