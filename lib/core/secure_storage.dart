/// Secure key-value storage service
library secure_storage;

/// Secure storage interface
abstract class ISecureStorage {
  /// Write secure value
  Future<void> write({
    required String key,
    required String value,
  });

  /// Read secure value
  Future<String?> read(String key);

  /// Delete secure value
  Future<void> delete(String key);

  /// Check if key exists
  Future<bool> contains(String key);

  /// Clear all values
  Future<void> clear();
}

/// In-memory secure storage implementation
class SecureStorageService implements ISecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String value,
  }) async {
    _storage[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<bool> contains(String key) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }

  /// Get all keys
  Future<List<String>> getAllKeys() async => _storage.keys.toList();
}

/// Secure storage keys constants
class SecureStorageKeys {
  static const String apiToken = 'api_token_key';
  static const String refreshToken = 'refresh_token_key';
  static const String userId = 'user_id_key';
  static const String deviceId = 'device_id_key';
  static const String encryptionKey = 'encryption_key';
  static const String lastSyncTime = 'last_sync_time';
  static const String userPreferences = 'user_preferences';
}
