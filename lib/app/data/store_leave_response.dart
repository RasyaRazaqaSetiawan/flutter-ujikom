class StoreLeaveResponse {
  final bool? success;
  final Data? data;
  final String? message;

  StoreLeaveResponse({this.success, this.data, this.message});

  factory StoreLeaveResponse.fromJson(Map<String, dynamic> json) {
    return StoreLeaveResponse(
      success: json['success'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
      'message': message,
    };
  }
}

class Data {
  final int? userId;
  final String? categoriesLeave;
  final String? startDate;
  final String? endDate;
  final String? reason;
  final String? status;
  final String? scheduleOffice;
  final String? attachment;
  final String? updatedAt;
  final String? createdAt;
  final int? id;
  final User? user;
  final String? attachmentUrl;

  Data({
    this.userId,
    this.categoriesLeave,
    this.startDate,
    this.endDate,
    this.reason,
    this.status,
    this.scheduleOffice,
    this.attachment,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.user,
    this.attachmentUrl,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      userId: json['user_id'],
      categoriesLeave: json['categories_leave'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      reason: json['reason'],
      status: json['status'],
      scheduleOffice: json['schedule_office'],
      attachment: json['attachment'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      attachmentUrl: json['attachment_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'categories_leave': categoriesLeave,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
      'status': status,
      'schedule_office': scheduleOffice,
      'attachment': attachment,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
      'user': user?.toJson(),
      'attachment_url': attachmentUrl,
    };
  }
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? gender;
  final String? dateOfBirth;
  final String? phoneNumber;
  final String? address;
  final String? emailVerifiedAt;
  final String? profilePhoto;
  final String? sessionToken;
  final String? sessionId;
  final String? lastLoginAt;
  final String? lastLoginIp;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.address,
    this.emailVerifiedAt,
    this.profilePhoto,
    this.sessionToken,
    this.sessionId,
    this.lastLoginAt,
    this.lastLoginIp,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      emailVerifiedAt: json['email_verified_at'],
      profilePhoto: json['profile_photo'],
      sessionToken: json['session_token'],
      sessionId: json['session_id'],
      lastLoginAt: json['last_login_at'],
      lastLoginIp: json['last_login_ip'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'phone_number': phoneNumber,
      'address': address,
      'email_verified_at': emailVerifiedAt,
      'profile_photo': profilePhoto,
      'session_token': sessionToken,
      'session_id': sessionId,
      'last_login_at': lastLoginAt,
      'last_login_ip': lastLoginIp,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
