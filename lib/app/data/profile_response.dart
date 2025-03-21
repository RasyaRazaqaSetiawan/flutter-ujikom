class ProfileResponse {
  bool? success;
  Data? data;
  String? message;

  ProfileResponse({this.success, this.data, this.message});

  ProfileResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String? accessToken;
  String? tokenType;
  User? user;

  Data({this.accessToken, this.tokenType, this.user});

  Data.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    user = json['user'] != null ? new User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['token_type'] = this.tokenType;
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? email;
  String? gender;
  String? phoneNumber;
  String? address;
  String? dateOfBirth;
  String? profilePhoto;

  User(
      {this.id,
      this.name,
      this.email,
      this.gender,
      this.phoneNumber,
      this.address,
      this.dateOfBirth,
      this.profilePhoto});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    dateOfBirth = json['date_of_birth'];
    profilePhoto = json['profile_photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['phone_number'] = this.phoneNumber;
    data['address'] = this.address;
    data['date_of_birth'] = this.dateOfBirth;
    data['profile_photo'] = this.profilePhoto;
    return data;
  }
}