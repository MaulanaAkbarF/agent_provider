class ListServices {
  String? status;
  List<ListServicesData> data;

  ListServices({
    this.status,
    required this.data,
  });

  factory ListServices.fromJson(Map<String, dynamic> json) => ListServices(
    status: json["status"] ?? '',
    data: List<ListServicesData>.from(json["data"].map((x) => ListServicesData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };

}

class ListServicesData {
  int id;
  String? name;
  String? description;
  String? iconUrl;
  ListServicesRegistrationStatus? registrationStatus;

  ListServicesData({
    required this.id,
    this.name,
    this.description,
    this.iconUrl,
    this.registrationStatus,
  });

  factory ListServicesData.fromJson(Map<String, dynamic> json) => ListServicesData(
    id: json["id"],
    name: json["name"] ?? '',
    description: json["description"] ?? '',
    iconUrl: json["icon_url"] ?? '',
    registrationStatus: registrationStatusValues.map[json["registration_status"]] ?? ListServicesRegistrationStatus.NOT_REGISTERED,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "icon_url": iconUrl,
    "registration_status": registrationStatusValues.reverse[registrationStatus],
  };

}

enum ListServicesRegistrationStatus {
  NOT_REGISTERED, PENDING
}

final registrationStatusValues = EnumValues({
  "Not Registered": ListServicesRegistrationStatus.NOT_REGISTERED,
  "Pending": ListServicesRegistrationStatus.PENDING
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
