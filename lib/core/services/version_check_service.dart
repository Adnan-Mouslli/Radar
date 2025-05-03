import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:radar/core/constant/Link.dart';
import 'package:radar/core/services/services.dart';

class VersionCheckService extends GetxService {
  final String baseUrl = AppLink.server;
  String get versionCheckUrl => '$baseUrl/api/users/check-update';
  final MyServices myServices = Get.find();

  Future<bool> needsUpdate() async {
    try {
      final currentVersion = await _getCurrentAppVersion();
      final data = await _getLatestAppVersion();

      if (currentVersion == null ||
          data == null ||
          !data.containsKey("version")) {
        return false;
      }

      final latestVersion = data["version"];
      final isRequired = data["isRequired"] ?? false;
      final WeeklyJewelValue = data["WeeklyJewelValue"] ?? 1000;

      final phoneReelWin = data["phoneReelWin"] ?? "+963941325008";

      myServices.saveData("WeeklyJewelValue", WeeklyJewelValue);
      myServices.saveData("phoneReelWin", phoneReelWin);

      if (!isRequired) {
        return false;
      }

      return _compareVersions(currentVersion, latestVersion);
    } catch (e) {
      print('خطأ في التحقق من الإصدار: $e');
      return false;
    }
  }

  Future<String?> _getCurrentAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (e) {
      print('خطأ في الحصول على إصدار التطبيق: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getLatestAppVersion() async {
    try {
      final response = await http.get(Uri.parse(versionCheckUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('خطأ في الاستجابة: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('خطأ في الاتصال بالخادم: $e');
      return null;
    }
  }

  bool _compareVersions(String currentVersion, String latestVersion) {
    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < math.min(current.length, latest.length); i++) {
      if (latest[i] > current[i]) {
        return true;
      } else if (latest[i] < current[i]) {
        return false;
      }
    }
    return latest.length > current.length;
  }
}
