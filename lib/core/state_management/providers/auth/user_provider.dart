// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_auth/firebase_auth.dart' hide User;
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:convert';

import 'package:agent/core/models/_global_widget_model/geocoding.dart';
import 'package:agent/core/utilities/extensions/primitive_data/string_ext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/auth_model/data_user.dart';
import '../../../services/http_services/endpoints/auth/auth_services.dart';
import '../../../utilities/functions/logger_func.dart';

class UserProvider extends ChangeNotifier {
  UserAuth? _auth;
  GeocodingModel _userAddressSelected = GeocodingModel(latitude: 0, longitude: 0);
  String _phoneNumber = '';

  UserAuth? get auth => _auth;
  GeocodingModel get userAddressSelected => _userAddressSelected;
  User? get user => _auth?.user;
  String get phoneNumber => _phoneNumber;
  bool get isLoggedIn => _auth != null;

  /// Fungsi untuk mengisiasi data user di awal dengan mengambil data tersimpan di dalam Shared Preferences
  Future<bool> initialize() async {
    var pref = await AuthHelper.instance();
    if (pref.userAuth != null) {
      _auth = pref.userAuth;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Fungsi ketika pengguna melakukan request OTP
  Future<bool> requestOTP({required BuildContext context, required String phoneNumber}) async {
    try {
      _phoneNumber = phoneNumber;
      return await AuthServiceHttp(context).requestOtp(phoneNumber);
    } catch (e, s) {
      clog('Terjadi masalah saat Request OTP: $e\n$s');
      return false;
    }
  }

  /// Fungsi ketika pengguna melakukan verify OTP
  Future<bool> verifyOtp({required BuildContext context, required String otpCode}) async {
    try {
      UserAuth? auth = await AuthServiceHttp(context).verifyOtp(_phoneNumber, otpCode);
      if (auth != null) {
        setAuth(auth);
        return true;
      }
      return false;
    } catch (e, s) {
      clog('Terjadi masalah saat Verify OTP: $e\n$s');
      return false;
    }
  }

  /// Fungsi ketika token pengguna saat ini sudah kadaluarsa/expires/unauthenticated
  Future<void> refresh({required BuildContext context}) async {
    try {
      // Belum ada fungsi refresh cuy di BE
    } catch (e) {
      clog('Refresh Token Error: $e');
      await logout(context);
    }
  }

  /// Fungsi untuk menetapkan data Auth/User aktif saat ini dan menyimpannya ke Shared Preferences
  Future<void> setAuth(UserAuth? value) async {
    _auth = value;
    await AuthHelper.instance().then((shared) => shared.userAuth = _auth);
    if (_auth == null) clog('Auth Kosong!');
    if (_auth != null) clog('Berhasil menetapkan UserAuth!\n${jsonEncode(_auth?.toJson()).convertToJsonStyle}');
    notifyListeners();
  }

  /// Fungsi untuk menetapkan alamat sementara yang dipilih saat proses update profil
  Future<void> setUserAddressSelected(GeocodingModel data) async {
    if (data.address != null || data.address != 'Indonesia'){
      _userAddressSelected = data;
      notifyListeners();
    }
  }

  Future<void> setUserAddressSelectedNull() async {
    clog('RUNTHIS setUserAddressSelectedNull');
    _userAddressSelected = GeocodingModel(latitude: 0, longitude: 0);
    notifyListeners();
  }

  /// Fungsi untuk menetapkan alamat sementara yang dipilih saat proses update profil
  void updateUserData(User? data) {
    if (data != null){
      String? token = _auth?.token;
      int? userId = _auth?.user.id;
      String? userPhone = _auth?.user.phoneNumber;
      clog('updateUserData Gender: ${data.gender}');
      setAuth(
        UserAuth(
          token: token,
          user: User(
            id: userId ?? 0,
            name: data.name,
            email: data.email,
            gender: data.gender,
            address: data.address,
            latitude: data.latitude,
            longitude: data.longitude,
            phoneNumber: userPhone ?? '',
          )
        )
      );
      notifyListeners();
    }
  }

  /// Fungsi ketika pengguna melakukan logout
  Future<void> logout(BuildContext context) async {
    try {
      clog('Logout berhasil');
    } catch (e) {
      clog('Logout Error: $e');
      await setAuth(null);
    }
  }

  static UserProvider read(BuildContext context) => context.read();
  static UserProvider watch(BuildContext context) => context.watch();
}

/// Class untuk menyimpan data Auth Setting ke dalam Shared Preferences
class AuthHelper {
  final SharedPreferences shared;

  AuthHelper(this.shared);

  set userAuth(UserAuth? userAuth) {
    if (userAuth == null) {
      shared.remove("auth");
    } else {
      shared.setString("auth", jsonEncode(userAuth.toJson()));
    }
  }

  UserAuth? get userAuth {
    if (shared.getString("auth") != null) return UserAuth.fromJson(jsonDecode(shared.getString("auth")!));
    return null;
  }

  static Future<AuthHelper> instance() => SharedPreferences.getInstance().then((value) => AuthHelper(value));
}
