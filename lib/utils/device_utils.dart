import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static Future<String?> getAndroidId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  static const List<String> allowedDeviceIds = [
    'ID_DO_SEU_APARELHO',
    'ID_DO_FILHO_1',
    'ID_DO_FILHO_2',
  ];

  static Future<bool> isDeviceAllowed() async {
    final id = await getAndroidId();
    return allowedDeviceIds.contains(id);
  }
}
