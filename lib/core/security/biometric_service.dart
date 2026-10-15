import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

enum BiometricAuthResult {
  success,
  failed,
  notAvailable,
  hardwareUnavailable,
  userCanceled,
}

/// Serviço de Autenticação Biométrica (TouchID, FaceID, Leitor de Digital).
///
/// **Relevância para a Secretaria do Estado do RJ:**
/// Garante que a abertura do app ou a confirmação de transferências/autorizações fiscais
/// só possam ser realizadas pelo proprietário legítimo do dispositivo móvel.
class BiometricService {
  final LocalAuthentication _auth;

  BiometricService({LocalAuthentication? auth}) : _auth = auth ?? LocalAuthentication();

  /// Verifica se o dispositivo possui hardware biométrico configurado e ativo
  Future<bool> isBiometricsSupported() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Retorna os tipos de biometria cadastrados no aparelho (Face, Fingerprint, Iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Dispara o prompt nativo de autenticação biométrica do sistema operacional
  Future<BiometricAuthResult> authenticate({
    String reason = 'Confirme sua identidade para acessar o FinFlow',
  }) async {
    final supported = await isBiometricsSupported();
    if (!supported) {
      return BiometricAuthResult.notAvailable;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Permite fallback seguro para PIN/Senha do dispositivo
          useErrorDialogs: true,
        ),
      );

      return authenticated ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        return BiometricAuthResult.hardwareUnavailable;
      } else if (e.code == 'PasscodeNotSet') {
        return BiometricAuthResult.notAvailable;
      }
      return BiometricAuthResult.userCanceled;
    } catch (_) {
      return BiometricAuthResult.failed;
    }
  }
}

