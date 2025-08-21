import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../constant_values/_setting_value/log_app_values.dart';
import '../../constant_values/_utlities_values.dart';
import '../../state_management/providers/auth/user_provider.dart';
import '../../utilities/functions/logger_func.dart';
import '../../utilities/functions/system_func.dart';
import '../../utilities/local_storage/sqflite/services/_setting_services/log_app_services.dart';
import '_global_url.dart';

Response? failedResponse;
Dio globalDio = Dio(
  BaseOptions(
    baseUrl: ApiService.getEndpoint(),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    validateStatus: (status) => true,

  ),
);

abstract class HttpConnection {
  final BuildContext context;

  Dio get _dio => globalDio;

  HttpConnection(this.context);

  /*
    Fungsi untuk melakukan request ke API.
    Anda perlu menentukan metod apa yang digunakan, seperti POST, GET, PUT, DELETE.
    Kemudian menangani respon apabila data berhasil diterima dan data gagal diterima.

    Contoh kode pemaggilan:
    Future<Response?> sendRequest(String data) async {
      Response? resp = await dioRequest(DioMethod.post, '${ApiService.getEndpoint()}/your-endpoint');
      if (resp != null){
        // eksekusi logika Anda
        return resp;
      }
      // Jika respon kosong, kembalikan null
      return null;
    }
   */
  Future dioRequest(DioMethod method, String url, {Map<String, String>? params, dynamic body, dynamic headers, bool pure = false}) async {
    try {
      clog(url);
      await checkInternetConnectivity().then((conn) {
        if (!conn) throw HttpErrorConnection(status: 503, description: "Koneksi internet tidak tersedia", message: "Server tidak dapat memproses permintaan Anda");
        return;
      });
      headers = _preRequestHeaders(headers);
      Response resp;
      switch (method){
        case DioMethod.get: resp = await _dio.get(url + paramsToString(params), options: Options(headers: headers));
        case DioMethod.post: resp = await _dio.post(url + paramsToString(params), data: body, options: Options(headers: headers));
        case DioMethod.put: resp = await _dio.put(url + paramsToString(params), data: body, options: Options(headers: headers));
        case DioMethod.patch: resp = await _dio.patch(url + paramsToString(params), data: body, options: Options(headers: headers));
        case DioMethod.delete: resp = await _dio.delete(url + paramsToString(params), data: body, options: Options(headers: headers));
      }

      clog("Response Request!\nMethod: ${method.name}\nHeader: $headers\nURL: $url\n"
        "Body: $body${paramsToString(params)}\nStatus Code: ${resp.statusCode}\nResponse Data: ${resp.data}");
      if (!_postRequestHeaders(resp)) return;
      if (pure) return resp.data;
      if (resp.data != null) {
        return ApiResponse.fromJson(resp.data, resp.statusCode ?? 999);
      }
    } on DioException catch (e, s) {
      clog('DioException: $url.\n$e\n$s');
      return dioException(e);
    } catch (e, s) {
      clog('Terjadi kesalahan saat mengakses Endpoint: $url.\n$e\n$s');
      await addLogApp(level: ListLogAppLevel.critical.level, statusCode: failedResponse?.statusCode, title: e.toString(), logs: s.toString());
      return;
    }
  }

  /// Fungsi yang dijalankan sebelum melakukan request ke API
  Map<String, String>? _preRequestHeaders(Map<String, String>? headers) {
    var userProvider = UserProvider.read(context);
    /// Jika terdapat access token, header akan selalu/wajib ditambahkan Bearer Token
    if (userProvider.auth?.accessToken != null) {
      if (headers != null) {
        headers.addEntries([MapEntry("Authorization", "Bearer ${userProvider.auth?.accessToken}")]);
      } else {
        headers = {"Authorization": "Bearer ${userProvider.auth?.accessToken}"};
      }
    }
    return headers;
  }

  /// Fungsi yang dijalankan setelah melakukan request ke API
  bool _postRequestHeaders(Response response) {
    if (response.statusCode == null) throw Exception("Application error on requests");
    if (response.statusCode == 401) {
      ///Implement refresh token ketimbang suruh user login lagi
      UserProvider.read(context).refresh(context: context);
      throw HttpErrorConnection(status: 401, description: "Token kadaluarsa", message: "Memproses sesi baru");
    }
    if (response.statusCode! > 300) {
      failedResponse = response;
      // Handle saat kondisi status code bukan 200
      return false;
    }
    return true;
  }

  /// Fungsi untuk menangani kondisi pada exception yang dihasilkan oleh DioException
  Future dioException(DioException e) async {
    if (e.response?.statusCode == 401) return await UserProvider.read(context).refresh(context: context);
    if (e.response?.statusCode == 404) {
      await addLogApp(level: ListLogAppLevel.critical.level, statusCode: 404, title: e.type.name, logs: "Akses tidak ditemukan");
      throw HttpErrorConnection(status: 404, description: e.type.name, message: "Akses tidak ditemukan");
    }
    if (e.type == DioExceptionType.connectionError) {
      await addLogApp(level: ListLogAppLevel.critical.level, statusCode: 503, title: e.type.name, logs: "Tidak dapat terhubung ke server. Pastikan server API berjalan.");
      throw HttpErrorConnection(status: 503, description: e.type.name, message: "Tidak dapat terhubung ke server. Pastikan server API berjalan.");
    }
    throw HttpErrorConnection(status: e.response?.statusCode ?? -1, description: e.type.name, message: e.message ?? "Application internal error");
  }

  static String paramsToString(Map<String, String>? params) {
    if (params == null) return "";
    String output = "?";
    params.forEach((key, value) {
      output += "$key=$value&";
    });
    return output.substring(0, output.length - 1);
  }
}

class ApiResponse<T>{
  ApiResponse({
    this.message,
    this.data,
    required this.statusCode,
    required this.status,
  });

  final int statusCode;
  final String status;
  bool get success => statusCode >= 200 && statusCode < 300;
  String? message;
  T? data;

  factory ApiResponse.fromJson(Map<String, dynamic> json, int code) => ApiResponse(
    statusCode: code,
    status: json["status"] ?? '',
    message: json["message"] ?? '',
    data: json["result"] ?? [],
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "status": status,
    "success": success,
    "message": message,
    "result": data,
  };
}

class HttpErrorConnection implements Exception {
  final int status;
  final String message;
  final String description;

  HttpErrorConnection({required this.status, required this.message, required this.description});

  @override
  String toString() {
    return "Error $status, $message, $description";
  }
}
