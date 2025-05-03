class AppConstants {
  // App Settings
  static const String appName = "Reel Reward";
  static const String appVersion = "1.0.0";

  // Local Storage Keys
  static const String tokenKey = "token";
  static const String userKey = "user";
  static const String langKey = "language";
  static const String themeKey = "theme";

  // API Settings
  static const String baseUrl = "https://api.example.com";
  static const int apiTimeOut = 30000; // 30 seconds

  // App Defaults
  static const String defaultLang = "ar";
  static const int pageSize = 10;
  static const int maxReelsToLoad = 20;

  // File Paths
  static const String imagePath = "assets/images";
  static const String videoPath = "assets/videos";
  static const String iconPath = "assets/icons";

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int maxUsernameLength = 20;

  // Reward System
  static const int pointsPerView = 10;
  static const int minPointsToRedeem = 1000;
}