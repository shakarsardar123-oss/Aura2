import 'package:aura_assistant/core/errors/result.dart';
import '../models/memory_entry.dart';
import '../models/memory_failure.dart';

abstract class MemoryStorageService {
  Future<Result<MemoryEntry, MemoryFailure>> store(MemoryEntry entry);
  Future<Result<MemoryEntry, MemoryFailure>> recall(String id);
  Future<Result<List<MemoryEntry>, MemoryFailure>> search(String query);
  Future<Result<void, MemoryFailure>> delete(String id);
}
