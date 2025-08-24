import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../ui/layouts/global_state_widgets/modal_bottom_sheet/exception_bottom_sheet.dart';
import '../../constant_values/_setting_value/log_app_values.dart';
import '../../constant_values/_utlities_values.dart';
import '../../state_management/providers/auth/user_provider.dart';
import '../../utilities/functions/logger_func.dart';
import '../../utilities/functions/system_func.dart';
import '../../utilities/local_storage/sqflite/services/_setting_services/log_app_services.dart';
import '_global_url.dart';
import 'exceptions.dart';

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
        if (!conn) {
          showExceptionModalBottomSheet(context, NetworkException(status: 503, description: "", message: ''));
          throw NetworkException(status: 503, description: "Koneksi internet terputus", message: "Server tidak dapat memproses permintaan Anda");
        }
      });
      headers = _preRequestHeaders(headers);
      Response resp;
      switch (method){
        case DioMethod.get: resp = await _dio.get(url + _paramsToString(params), options: Options(headers: headers));
        case DioMethod.post: resp = await _dio.post(url + _paramsToString(params), data: body, options: Options(headers: headers));
        case DioMethod.put: resp = await _dio.put(url + _paramsToString(params), data: body, options: Options(headers: headers));
        case DioMethod.patch: resp = await _dio.patch(url + _paramsToString(params), data: body, options: Options(headers: headers));
        case DioMethod.delete: resp = await _dio.delete(url + _paramsToString(params), data: body, options: Options(headers: headers));
      }

      clog("Response Request!\nMethod: ${method.name}\nHeader: $headers\nURL: $url\n"
        "Body: $body${_paramsToString(params)}\nStatus Code: ${resp.statusCode}\nResponse Data: ");
      clog(resp.data);
      if ((resp.statusCode != null) && resp.statusCode! >= 300) _handleExceptions(DioException(response: resp, requestOptions: resp.requestOptions));
      if (pure) return resp.data;
      if (resp.data != null) {
        return ApiResponse.fromJson(resp.data, resp.statusCode ?? 999);
      }
    } on DioException catch (e, s) {
      clog('DioException: $url.\n$e\n$s');
      return _handleExceptions(e);
    } on Exception catch (e, s) {
      clog('Terjadi kesalahan saat mengakses Endpoint: $url.\n$e\n$s');
      await addLogApp(level: ListLogAppLevel.critical.level, statusCode: failedResponse?.statusCode, title: e.toString(), logs: s.toString());
      return ApiResponse(statusCode: 404, status: e.toString(), data: e);
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

  /// Fungsi untuk menangani response dan DioException
  Future _handleExceptions(DioException e) async {
    switch (e.response?.statusCode){
      case 400 :
        showExceptionModalBottomSheet(context, BadRequestException(status: 400, message: ''));
        throw BadRequestException(status: e.response!.statusCode!, message: e.response!.statusMessage ?? 'Terjadi msalaah');
      case 401 :
        showExceptionModalBottomSheet(context, UnauthorizedException(status: 401, message: ''));
        throw UnauthorizedException(status: e.response!.statusCode!, message: e.response!.statusMessage ?? 'Terjadi msalaah');
      case 402 :
        showExceptionModalBottomSheet(context, AccountBlockedException(status: 402, message: ''));
        throw AccountBlockedException(status: e.response!.statusCode!, message: e.response!.statusMessage ?? 'Terjadi msalaah');
      case 422 :
        showExceptionModalBottomSheet(context, UnprocessableEntityException(status: 422, message: ''));
        throw UnprocessableEntityException(status: e.response!.statusCode!, message: e.response!.statusMessage ?? 'Terjadi msalaah');
      default :
        showExceptionModalBottomSheet(context, UnknownException(status: 999, message: ''));
        throw UnknownException(status: e.response!.statusCode!, message: e.response!.statusMessage ?? 'Terjadi msalaah');
    }
  }

  static String _paramsToString(Map<String, String>? params) {
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
    data: json["data"] ?? {},
  );

  Map<String, dynamic> toJson() => {
    "status_code": statusCode,
    "status": status,
    "success": success,
    "message": message,
    "result": data,
  };
}
