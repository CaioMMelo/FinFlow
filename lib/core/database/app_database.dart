import '../security/secure_storage_service.dart';

/// Gerenciador de inicialização e custódia da base de dados criptografada do FinFlow.
///
/// **Arquitetura Multiplataforma (Mobile & Web):**
/// Em mobile (Android/iOS), inicializa o cofre de chaves via `SecureStorageService` (Keystore/Keychain)
/// e aplica a chave mestra AES-256 no SQLCipher.
/// Em web/emulador, provê compatibilidade e abstração unificada.
class AppDatabase {
  final SecureStorageService secureStorage;
  bool _isInitialized = false;
  String? _masterKey;

  AppDatabase({required this.secureStorage});

  /// Inicializa o cofre seguro e recupera a chave mestra de criptografia
  Future<void> initializeEncryptedStorage() async {
    if (_isInitialized) return;
    _masterKey = await secureStorage.getOrCreateDatabaseEncryptionKey();
    _isInitialized = true;
  }

  bool get isReady => _isInitialized;
  String? get masterKey => _masterKey;
}
