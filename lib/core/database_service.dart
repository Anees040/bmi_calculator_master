/// Database service abstraction
library database_service;

/// Database service interface
abstract class IDatabaseService {
  Future<void> initialize();
  Future<Map<String, dynamic>> query(String sql, [List<dynamic>? args]);
  Future<List<Map<String, dynamic>>> queryList(String sql, [List<dynamic>? args]);
  Future<int> execute(String sql, [List<dynamic>? args]);
  Future<void> close();
  Future<void> backup(String path);
}

/// In-memory database implementation
class InMemoryDatabaseService implements IDatabaseService {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<Map<String, dynamic>> query(String sql,
      [List<dynamic>? args]) async {
    if (!_isInitialized) throw StateError('Database not initialized');
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> queryList(String sql,
      [List<dynamic>? args]) async {
    if (!_isInitialized) throw StateError('Database not initialized');
    return [];
  }

  @override
  Future<int> execute(String sql, [List<dynamic>? args]) async {
    if (!_isInitialized) throw StateError('Database not initialized');
    return 0;
  }

  @override
  Future<void> close() async {
    _tables.clear();
    _isInitialized = false;
  }

  @override
  Future<void> backup(String path) async {
    if (!_isInitialized) throw StateError('Database not initialized');
  }

  /// Insert data
  Future<int> insert(String table, Map<String, dynamic> data) async {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    _tables[table]!.add(data);
    return _tables[table]!.length;
  }

  /// Get all from table
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    return _tables[table] ?? [];
  }

  /// Get table count
  Future<int> count(String table) async {
    return _tables[table]?.length ?? 0;
  }

  /// Clear table
  Future<void> clearTable(String table) async {
    _tables[table] = [];
  }
}

/// Database transaction
class DatabaseTransaction {
  final IDatabaseService _service;
  final List<String> _operations = [];
  bool _committed = false;

  DatabaseTransaction(this._service);

  /// Add operation
  void addOperation(String sql, [List<dynamic>? args]) {
    _operations.add(sql);
  }

  /// Commit all operations
  Future<void> commit() async {
    for (final operation in _operations) {
      await _service.execute(operation);
    }
    _committed = true;
  }

  /// Check if committed
  bool get isCommitted => _committed;
}
