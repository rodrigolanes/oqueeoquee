import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  /// Retorna o identificador único do dispositivo Android
  /// Gera um hash baseado em informações estáveis do dispositivo
  static Future<String?> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    // Combina informações únicas do dispositivo para criar um ID estável
    final deviceSignature = '${androidInfo.board}'
        '${androidInfo.brand}'
        '${androidInfo.device}'
        '${androidInfo.hardware}'
        '${androidInfo.id}'
        '${androidInfo.manufacturer}'
        '${androidInfo.model}'
        '${androidInfo.product}';

    // Gera hash SHA-256 e pega os primeiros 16 caracteres
    final bytes = utf8.encode(deviceSignature);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  /// Lista de IDs de dispositivos autorizados para funções administrativas
  /// Para descobrir o ID do seu dispositivo, acesse a tela de Debug (3 toques no título)
  static const List<String> allowedDeviceIds = [
    // Adicione os IDs dos dispositivos autorizados aqui
    // Exemplo: '9774d56d682e549c' (16 caracteres hexadecimais)
  ];

  static Future<bool> isDeviceAllowed() async {
    final id = await getAndroidId();
    return allowedDeviceIds.contains(id);
  }
}
