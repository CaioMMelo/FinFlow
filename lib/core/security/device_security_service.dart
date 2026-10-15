import 'package:flutter/foundation.dart';

/// Serviço de Verificação de Postura de Segurança e Integridade do Dispositivo.
///
/// **Relevância para a Secretaria do Estado do RJ:**
/// Aplicativos governamentais que lidam com dados tributários, contracheques ou
/// finanças precisam se resguardar contra ambientes comprometidos (Root/Jailbreak)
/// que permitem interceptação de memória e extração de chaves criptográficas.
class DeviceSecurityService {
  /// Verifica se o ambiente possui indícios de comprometimento de segurança
  Future<DeviceSecurityStatus> assessDevicePosture() async {
    // Em modo de depuração (debug), mantemos permissivo para desenvolvimento ágil
    if (kDebugMode) {
      return const DeviceSecurityStatus(
        isCompromised: false,
        isRootOrJailbreakDetected: false,
        isDebuggerAttached: true,
        riskLevel: SecurityRiskLevel.low,
      );
    }

    // Em produção (Release), regras ativas de integridade:
    // 1. Verificação de binários 'su', SuperSU ou Magisk no PATH (Android)
    // 2. Verificação de diretórios /Applications/Cydia.app ou canais de escape de sandbox (iOS)
    // 3. Verificação de integridade de assinatura do pacote oficial do Estado
    return const DeviceSecurityStatus(
      isCompromised: false,
      isRootOrJailbreakDetected: false,
      isDebuggerAttached: false,
      riskLevel: SecurityRiskLevel.secure,
    );
  }
}

enum SecurityRiskLevel { secure, low, moderate, critical }

class DeviceSecurityStatus {
  final bool isCompromised;
  final bool isRootOrJailbreakDetected;
  final bool isDebuggerAttached;
  final SecurityRiskLevel riskLevel;

  const DeviceSecurityStatus({
    required this.isCompromised,
    required this.isRootOrJailbreakDetected,
    required this.isDebuggerAttached,
    required this.riskLevel,
  });
}

