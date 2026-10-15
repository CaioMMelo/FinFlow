import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço de armazenamento seguro com proteção de hardware.
///
/// **Relevância para a Secretaria do Estado do RJ / LGPD:**
/// No Android, utiliza o **Android Keystore Provider** (chaves armazenadas em hardware TEE/StrongBox).
/// No iOS, utiliza a **Keychain** com proteção `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`.
/// Impede que chaves de banco ou tokens de sessão fiquem salvos em SharedPreferences desprotegidos.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: false,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const _dbEncryptionKeyName = 'finflow_database_master_key_aes256';
  static const _biometricEnabledKey = 'finflow_biometrics_enabled';

  /// Obtém a chave mestra de criptografia do banco local ou gera uma nova de 256 bits se for o primeiro acesso.
  Future<String> getOrCreateDatabaseEncryptionKey() async {
    String? key = await _storage.read(key: _dbEncryptionKeyName);

    if (key == null) {
      // Gera uma chave criptográfica forte de 32 bytes (256 bits)
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      key = base64UrlEncode(values);

      await _storage.write(key: _dbEncryptionKeyName, value: key);
    }

    return key;
  }

  /// Salva a preferência de exigência de biometria
  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  /// Verifica se o usuário exige biometria para abrir o app
  Future<bool> isBiometricsEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    // Por padrão em apps financeiros do Estado, biometria vem habilitada
    return value == null ? true : value.toLowerCase() == 'true';
  }

  /// Limpa todos os dados sensíveis (Logout seguro / Redefinição)
  Future<void> wipeAllKeys() async {
    await _storage.deleteAll();
  }
}

