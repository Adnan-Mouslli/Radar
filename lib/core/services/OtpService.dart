import 'package:radar/core/class/statusrequest.dart';

import '../../../../core/class/crud.dart';
import '../../../../core/constant/Link.dart';
import 'package:dartz/dartz.dart';

class OtpService {
  Crud crud;

  OtpService(this.crud);

  Future<Either<StatusRequest, Map>> sendOtp(
      String phoneNumber, String otp) async {
    print("sendOtp: ${phoneNumber} , otp: ${otp}");

    var response = await crud.postData(AppLink.sendOtp, {
      "phoneNumber": phoneNumber,
      "otp": otp,
    });

    print("OTP Response: $response");
    return response;
  }

  Future<Either<StatusRequest, Map>> reSendOtp(String phoneNumber) async {
    print("resendOtp: ${phoneNumber}");
    var response = await crud.postData(
        AppLink.reSendOtp, {"phoneNumber": phoneNumber, "purpose": "SIGNUP"});

    print("Response: $response");
    return response;
  }
}
