class ScheduleResponse {
  String? status;
  String? message;
  Data? data;

  ScheduleResponse({this.status, this.message, this.data});

  ScheduleResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? employeeName;
  Office? office;
  Shift? shift;
  bool? isWfa;

  Data({this.employeeName, this.office, this.shift, this.isWfa});

  Data.fromJson(Map<String, dynamic> json) {
    employeeName = json['employee_name'];
    office =
        json['office'] != null ? new Office.fromJson(json['office']) : null;
    shift = json['shift'] != null ? new Shift.fromJson(json['shift']) : null;
    isWfa = json['is_wfa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['employee_name'] = this.employeeName;
    if (this.office != null) {
      data['office'] = this.office!.toJson();
    }
    if (this.shift != null) {
      data['shift'] = this.shift!.toJson();
    }
    data['is_wfa'] = this.isWfa;
    return data;
  }
}

class Office {
  int? id;
  String? name;
  double? latitude;
  double? longitude;
  int? radius;
  String? address;
  String? createdAt;
  String? updatedAt;

  Office(
      {this.id,
      this.name,
      this.latitude,
      this.longitude,
      this.radius,
      this.address,
      this.createdAt,
      this.updatedAt});

  Office.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
    address = json['address'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['radius'] = this.radius;
    data['address'] = this.address;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

class Shift {
  int? id;
  String? name;
  String? startTime;
  String? endTime;
  String? createdAt;
  String? updatedAt;

  Shift(
      {this.id,
      this.name,
      this.startTime,
      this.endTime,
      this.createdAt,
      this.updatedAt});

  Shift.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
