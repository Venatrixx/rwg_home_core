part of 'validation_catalog.dart';

/// Used to test one condition on an [ALevelWrapper] instance.
class ValidationTest<T> {
  /// The function that tests the condition.
  T Function(ALevelWrapper wrapper) test;

  /// A short description of the condition.
  String description;

  /// A reference to the article of the law this test is based on.
  String? reference;

  /// Instantiate a [ValidationTest) object.
  ValidationTest({required this.description, required this.test, this.reference});
}
