import 'dart:typed_data';

class LogAppCollection {
  int id;
  DateTime? logDate;
  String? level;
  int? statusCode;
  String? title;
  String? subtitle;
  String? description;
  String? logs;

  LogAppCollection({
    this.id = 0,
    this.logDate,
    this.level,
    this.statusCode,
    this.title,
    this.subtitle,
    this.description,
    this.logs,
  });

  factory LogAppCollection.fromMap(Map<String, dynamic> map) {
    return LogAppCollection(
      id: map['id'] ?? 0,
      logDate: map['logDate'] != null ? DateTime.parse(map['logDate']) : null,
      level: map['level'],
      statusCode: map['statusCode'],
      title: map['title'],
      subtitle: map['subtitle'],
      description: map['description'],
      logs: map['logs'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? 0 : id,
      'logDate': logDate?.toIso8601String(),
      'level': level,
      'statusCode': statusCode,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'logs': logs,
    };
  }
}

class PdfGenerationDataModelSetting {
  final List<Map<String, dynamic>> logData;
  final Uint8List fontBytes;
  final Map<String, String> deviceInfo;
  final String appName;
  final String appVersion;

  PdfGenerationDataModelSetting({
    required this.logData,
    required this.fontBytes,
    required this.deviceInfo,
    required this.appName,
    required this.appVersion,
  });
}