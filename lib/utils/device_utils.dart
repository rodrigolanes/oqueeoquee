import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  /// Retorna o identificador único do dispositivo Android
  /// Usa androidId que é único por dispositivo e instalação do Android
  static Future<String?> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Android ID único do dispositivo
  }

  /// Lista de Android IDs autorizados para funções administrativas
  /// Para descobrir o ID do seu dispositivo, acesse a tela de Debug (3 toques no título)
  static const List<String> allowedDeviceIds = [
    // Adicione os Android IDs reais dos dispositivos autorizados aqui
    // Exemplo: '9774d56d682e549c' (16 caracteres hexadecimais)
  ];

  static Future<bool> isDeviceAllowed() async {
    final id = await getAndroidId();
    return allowedDeviceIds.contains(id);
  }
}
