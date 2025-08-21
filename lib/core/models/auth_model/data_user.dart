

class UserAuth {
  // bool isVerify;
  String? accessToken;
  User user;

  UserAuth({
    // required this.isVerify,
    this.accessToken,
    required this.user,
  });

  factory UserAuth.fromJson(Map<String, dynamic> json) => UserAuth(
    // isVerify: json["is_verify"],
    accessToken: json["access_token"],
    user: User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    // "is_verify": isVerify,
    "access_token": accessToken,
    "user": user,
  };
}

class User {
  int id;
  String? name;
  String? email;
  String? gender;
  int phoneNumber;
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
    phoneNumber: json["phone_number"] ?? 0,
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