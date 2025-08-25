class UserAuth {
  String? token;
  User user;

  UserAuth({
    this.token,
    required this.user,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) => UserAuth(
    token: json["token"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user": user.toJson(),
  };
}

class User {
  int id;
  String? name;
  String? email;
  String? gender;
  String phoneNumber;
  String? address;
  String? latitude;
  String? longitude;
  String? avatarUrl;

  User({
    required this.id,
    this.name,
    this.email,
    this.gender,
    required this.phoneNumber,
    this.address,
    this.latitude,
    this.longitude,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"],
    email: json["email"],
    gender: json["gender"],
    phoneNumber: json["phone_number"]?.toString() ?? "0",
    address: json["address"],
    latitude: json["location_lat"],
    longitude: json["location_lng"],
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "gender": gender,
    "phone_number": phoneNumber,
    "address": address,
    "location_lat": latitude,
    "location_lng": longitude,
    "avatar_url": avatarUrl,
  };
}