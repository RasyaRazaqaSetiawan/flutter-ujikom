class AttendanceResponse {
  String? status;
  String? pesan;
  Data? data;

  AttendanceResponse({this.status, this.pesan, this.data});

  AttendanceResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    pesan = json['pesan'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['pesan'] = this.pesan;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  Absensi? absensi;
  String? urlFoto;
  String? tipe;

  Data({this.absensi, this.urlFoto, this.tipe});

  Data.fromJson(Map<String, dynamic> json) {
    absensi =
        json['absensi'] != null ? new Absensi.fromJson(json['absensi']) : null;
    urlFoto = json['url_foto'];
    tipe = json['tipe'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.absensi != null) {
      data['absensi'] = this.absensi!.toJson();
    }
    data['url_foto'] = this.urlFoto;
    data['tipe'] = this.tipe;
    return data;
  }
}

class Absensi {
  int? id;
  int? userId;
  String? date;
  double? scheduleLatitude;
  double? scheduleLongitude;
  String? scheduleStartTime;
  String? scheduleEndTime;
  double? latitude;
  double? longitude;
  String? startTime;
  String? endTime;
  String? status;
  String? checkInPhoto;
  String? checkOutPhoto;
  String? checkoutLatitude;
  String? checkoutLongitude;
  String? endTimeStatus;
  String? createdAt;
  String? updatedAt;

  Absensi(
      {this.id,
      this.userId,
      this.date,
      this.scheduleLatitude,
      this.scheduleLongitude,
      this.scheduleStartTime,
      this.scheduleEndTime,
      this.latitude,
      this.longitude,
      this.startTime,
      this.endTime,
      this.status,
      this.checkInPhoto,
      this.checkOutPhoto,
      this.checkoutLatitude,
      this.checkoutLongitude,
      this.endTimeStatus,
      this.createdAt,
      this.updatedAt});

  Absensi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    date = json['date'];
    scheduleLatitude = json['schedule_latitude'];
    scheduleLongitude = json['schedule_longitude'];
    scheduleStartTime = json['schedule_start_time'];
    scheduleEndTime = json['schedule_end_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    checkInPhoto = json['check_in_photo'];
    checkOutPhoto = json['check_out_photo'];
    checkoutLatitude = json['checkout_latitude'];
    checkoutLongitude = json['checkout_longitude'];
    endTimeStatus = json['end_time_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['date'] = this.date;
    data['schedule_latitude'] = this.scheduleLatitude;
    data['schedule_longitude'] = this.scheduleLongitude;
    data['schedule_start_time'] = this.scheduleStartTime;
    data['schedule_end_time'] = this.scheduleEndTime;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['status'] = this.status;
    data['check_in_photo'] = this.checkInPhoto;
    data['check_out_photo'] = this.checkOutPhoto;
    data['checkout_latitude'] = this.checkoutLatitude;
    data['checkout_longitude'] = this.checkoutLongitude;
    data['end_time_status'] = this.endTimeStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
