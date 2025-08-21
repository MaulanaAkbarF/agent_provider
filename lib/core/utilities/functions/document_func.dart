import 'dart:convert';
import 'dart:io';

import 'package:agent/core/utilities/functions/permission/storage_permission.dart';
import 'package:agent/core/utilities/functions/system_func.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../constant_values/_constant_text_values.dart';
import '../../constant_values/_setting_value/log_app_values.dart';
import '../../global_values/global_data.dart';
import '../../models/_settings_model/log_app.dart';
import '../local_storage/sqflite/services/_setting_services/log_app_services.dart';
import 'logger_func.dart';

/// Fungsi untuk mencetak log aplikasi dalam bentuk format JSON
Future<void> createLogAppJson(BuildContext context, List<LogAppCollection> data) async {
  if (data.isNotEmpty) {
    Directory? mainDirectory;
    String filePath;

    bool hasPermission = await getExternalStoragePermission();
    if (hasPermission) {
      mainDirectory = await getExternalStorageDirectory();
      if (mainDirectory != null) {
        try {
          List<LogAppCollection> limitedData = limitedLogAppData(data, 1000);
          Map<String, dynamic> jsonData = {
            'metadata': {
              'app_name': appNameText,
              'app_version': appVersionText,
              'export_date': DateTime.now().toIso8601String(),
              'total_logs': limitedData.length,
              'device_info': {
                'brand': UserDeviceInfo.brand.toString(),
                'model': UserDeviceInfo.model.toString(),
                'device': UserDeviceInfo.device.toString(),
                'manufacturer': UserDeviceInfo.manufacturer.toString(),
                'board': UserDeviceInfo.board.toString(),
                'hardware': UserDeviceInfo.hardware.toString(),
                'android_version': UserDeviceInfo.versionRelease.toString(),
                'codename': UserDeviceInfo.versionCodeName.toString(),
                'api_level': UserDeviceInfo.versionSdkInt.toString(),
                'is_physical_device': UserDeviceInfo.isPhysicalDevice.toString(),
              }
            },
            'logs': limitedData.map((log) => {
              'id': log.id.toString(),
              'level': log.level?.toString(),
              'log_date': log.logDate?.toString(),
              'status_code': log.statusCode?.toString(),
              'title': log.title?.toString(),
              'subtitle': log.subtitle?.toString(),
              'description': log.description?.toString(),
              'logs': processLogString(log.logs),
            }).toList(),
          };

          String jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
          filePath = '${mainDirectory.path}/log_app_${appNameText}_${DateTime.now().toString()}.json';
          await File(filePath).writeAsString(jsonString).then((value) => clog('File JSON berhasil disimpan di: ${value.path}'));
          showSnackBar(context, 'Dokumen Log Aplikasi JSON berhasil dibuat!\nJalur Penyimpanan: $filePath');
        } catch (e, s) {
          clog('Terjadi masalah saat createLogAppJson: $e\n$s');
          await addLogApp(level: ListLogAppLevel.severe.level, title: e.toString(), logs: s.toString());
        }
      } else {
        clog('Tidak mendapatkan External Direktori');
      }
    }
  } else {
    clog('Data Log Kosong');
  }
}

List<LogAppCollection> limitedLogAppData(List<LogAppCollection> data, int limit) {
  if (data.length > limit){
    data.sort((a, b) => b.id.compareTo(a.id));
    return data.take(limit).toList();
  } else {
    return data;
  }
}

dynamic processLogString(String? logString) {
  if (logString == null || logString.isEmpty || logString == "N/A") return "N/A";

  RegExp regExp = RegExp(r'#\d+');
  if (regExp.hasMatch(logString)) {
    Map<String, String> logMap = {};
    for (String part in logString.split(RegExp(r'(?=#\d+)'))) {
      if (part.trim().isEmpty) continue;
      Match? match = RegExp(r'^#(\d+)').firstMatch(part.trim());
      if (match != null) {
        String value = part.trim().substring(match.end).trim();
        if (value.startsWith(':') || value.startsWith('-')) value = value.substring(1).trim();
        logMap["#${match.group(1)}"] = value.isNotEmpty ? value : "N/A";
      }
    }

    return logMap.isNotEmpty ? logMap : logString;
  }

  return logString;
}