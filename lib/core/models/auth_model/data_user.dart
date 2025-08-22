class UserAuth {
  String? accessToken;
  User user;

  UserAuth({
    this.accessToken,
    required this.user,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) => UserAuth(
    accessToken: json["token"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "token": accessToken,
    "user": user.toJson(),
  };
}

class User {
  int id;
  String? name;
  String? email;
  String? gender;
  String phoneNumber;
  String? avatarUrl;

  User({
    required this.id,
    this.name,
    this.email,
    this.gender,
    required this.phoneNumber,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? 0,
    name: json["name"],
    email: json["email"],
    gender: json["gender"],
    phoneNumber: json["phone_number"]?.toString() ?? "0",
    avatarUrl: json["avatar_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "gender": gender,
    "phone_number": phoneNumber,
    "avatar_url": avatarUrl,
  };
}