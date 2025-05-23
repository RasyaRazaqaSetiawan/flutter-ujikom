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
  int? id;
  String? name;
  String? email;
  String? gender;
  String? phoneNumber;
  String? address;
  String? dateOfBirth;
  String? profilePhoto;
  String? profilePhotoName;
  String? employeeId;
  String? position;
  String? department;
  String? status;
  List<String>? roles;

  Data(
      {this.id,
      this.name,
      this.email,
      this.gender,
      this.phoneNumber,
      this.address,
      this.dateOfBirth,
      this.profilePhoto,
      this.profilePhotoName,
      this.employeeId,
      this.position,
      this.department,
      this.status,
      this.roles});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    phoneNumber = json['phone_number'];
    address = json['address'];
    dateOfBirth = json['date_of_birth'];
    profilePhoto = json['profile_photo'];
    profilePhotoName = json['profile_photo_name'];
    employeeId = json['employee_id'];
    position = json['position'];
    department = json['department'];
    status = json['status'];
    roles = json['roles'].cast<String>();
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
    data['profile_photo_name'] = this.profilePhotoName;
    data['employee_id'] = this.employeeId;
    data['position'] = this.position;
    data['department'] = this.department;
    data['status'] = this.status;
    data['roles'] = this.roles;
    return data;
  }
}
