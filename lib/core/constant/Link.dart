class AppLink {
  // device manager
  // static  String server = "http://10.0.2.2:8000";

  // mobile
  static String server = "https://anycode-sy.com/reel-win";

  static String test = "$server/test.php";

  // ========================== auth ============================//
  static String signUp = "$server/api/auth/signup";
  static String login = "$server/api/auth/signin";

  static  String forgetPasswordVerification = "$server/api/auth/forgot-password";
  static  String checkOtp = "$server/api/auth/verify-otp";
  static  String resetPassword = "$server/api/auth/reset-password";

    static  String verify = "$server/api/auth/verify";


  // Interests Routes
  static String interestsList = "$server/api/interests/list";

  static String sendOtp = "$server/api/auth/otp/verify";
  static String reSendOtp = "$server/api/auth/otp/resend";
}
