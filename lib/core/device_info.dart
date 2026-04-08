/// Device information service
library device_info;

import 'dart:io';

/// Device information
class DeviceInfo {
  final String deviceId;
  final String deviceName;
  final String osVersion;
  final String osName;
  final String appVersion;
  final bool isPhysicalDevice;
  final String screenSize; // 'small', 'normal', 'large', 'xlarge'
  final DateTime dateTime;

  DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.osVersion,
    required this.osName,
    required this.appVersion,
    required this.isPhysicalDevice,
    required this.screenSize,
  }) : dateTime = DateTime.now();

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'osVersion': osVersion,
    'osName': osName,
    'appVersion': appVersion,
    'isPhysicalDevice': isPhysicalDevice,
    'screenSize': screenSize,
  };
}

/// Device info service interface
abstract class IDeviceInfoService {
  Future<DeviceInfo> getDeviceInfo();
  Future<String> getDeviceId();
  bool get isConnected;
}

/// Device info service implementation
class DeviceInfoService implements IDeviceInfoService {
  static const String appVersion = '1.0.0';

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    return DeviceInfo(
      deviceId: 'device-${DateTime.now().millisecondsSinceEpoch}',
      deviceName: _getDeviceName(),
      osVersion: Platform.operatingSystemVersion,
      osName: Platform.operatingSystem,
      appVersion: appVersion,
      isPhysicalDevice: _isPhysicalDevice(),
      screenSize: 'normal',
    );
  }

  @override
  Future<String> getDeviceId() async {
    return 'device-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  bool get isConnected => true; // Simplified

  /// Get device name
  String _getDeviceName() {
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isIOS) return 'iOS Device';
    if (Platform.isWindows) return 'Windows Device';
    if (Platform.isLinux) return 'Linux Device';
    if (Platform.isMacOS) return 'macOS Device';
    return 'Unknown Device';
  }

  /// Check if physical device
  bool _isPhysicalDevice() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Get platform
  String getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }
}
