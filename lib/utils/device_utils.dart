import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static Future<String?> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  static const List<String> allowedDeviceIds = [
    'BP2A.250605.031.A3',
    'TP1A.220624.014',
    'ID_DO_FILHO_2',
    'UE1A.230829.036.A4', // Emulator Android
  ];

  static Future<bool> isDeviceAllowed() async {
    final id = await getAndroidId();
    return allowedDeviceIds.contains(id);
  }
}
