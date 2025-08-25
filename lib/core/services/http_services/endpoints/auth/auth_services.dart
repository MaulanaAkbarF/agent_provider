import 'dart:io';

import 'package:agent/core/constant_values/_utlities_values.dart';
import 'package:agent/core/models/_global_widget_model/geocoding.dart';
import 'package:agent/core/services/http_services/_global_url.dart';
import 'package:agent/core/services/http_services/http_connection.dart';
import 'package:agent/core/utilities/extensions/primitive_data/string_ext.dart';
import 'package:dio/dio.dart';

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

  Future<User?> updateUserProfile({String? name, String? email, String? gender, required String phoneNumber, GeocodingModel? address, File? photo}) async {
    if (phoneNumber == '') return null;
    ApiResponse? resp;
    if (photo != null) {
      resp = await dioRequest(DioMethod.patch, "${ApiService.getEndpoint()}/profile", body: FormData.fromMap({
        "name": name,
        "email": email,
        "gender": gender?.genderFormatted,
        "phone_number": phoneNumber,
        "address": address?.address ?? '',
        "latitude": address?.latitude ?? '',
        "longitude": address?.longitude ?? '',
        "avatar_url": await MultipartFile.fromFile(photo.path),
      }));
    } else {
      resp = await dioRequest(DioMethod.patch, "${ApiService.getEndpoint()}/profile", body: {
        "name": name,
        "email": email,
        "gender": gender?.genderFormatted,
        "phone_number": phoneNumber,
        "address": address?.address ?? '',
        "latitude": address?.latitude ?? '',
        "longitude": address?.longitude ?? '',
      });
    }
    if ((resp != null) && resp.success) return User.fromJson(resp.data);
    return null;
  }
}