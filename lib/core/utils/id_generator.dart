import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generates unique local ids for new records. Kept as its own tiny
/// abstraction so use cases depend on "a way to get a new id," not on
/// *how* one is produced.
abstract class IdGenerator {
  String generate();
}

class TimestampIdGenerator implements IdGenerator {
  const TimestampIdGenerator();

  @override
  String generate() => DateTime.now().microsecondsSinceEpoch.toString();
}

final idGeneratorProvider = Provider<IdGenerator>((ref) => const TimestampIdGenerator());
