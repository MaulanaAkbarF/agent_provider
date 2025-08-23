import 'package:agent/core/constant_values/_utlities_values.dart';
import 'package:agent/core/services/http_services/_global_url.dart';
import 'package:agent/core/services/http_services/http_connection.dart';

import '../../../../models/auth_model/data_user.dart';

class AuthServiceHttp extends HttpConnection {
  AuthServiceHttp(super.context);

  Future<bool> requestOtp(String phoneNumber) async {
    if (phoneNumber == '') return false;
    ApiResponse? resp = await dioRequest(DioMethod.post, "${ApiService.getEndpoint()}/auth/request", body: {
      'user_type': 'member',
      "phone_number": phoneNumber
    });
    if ((resp != null) && resp.success) return true;
    return false;
  }

  Future<UserAuth?> verifyOtp(String phoneNumber, String otpCode) async {
    if (otpCode == '') return null;
    ApiResponse? resp = await dioRequest(DioMethod.post, "${ApiService.getEndpoint()}/auth/verify", body: {
      'user_type': 'member',
      "phone_number": phoneNumber,
      "otp_code": otpCode
    });
    if ((resp != null) && resp.success) return UserAuth.fromJson(resp.data);
    return null;
  }
}