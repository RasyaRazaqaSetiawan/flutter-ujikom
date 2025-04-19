class StoreAttendanceResponse {
  String? status;
  String? message;
  Data? data;

  StoreAttendanceResponse({this.status, this.message, this.data});

  StoreAttendanceResponse.fromJson(Map<String, dynamic> json) {
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
  double? checkoutLatitude; 
  double? checkoutLongitude;
  String? checkoutStatus;
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
      this.checkoutStatus,
      this.createdAt,
      this.updatedAt});

  // Helper function to safely parse double values
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        print('Error parsing double value: $value - $e');
        return null;
      }
    }
    return null;
  }

  Absensi.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    date = json['date'];
    scheduleLatitude = _parseDouble(json['schedule_latitude']);
    scheduleLongitude = _parseDouble(json['schedule_longitude']);
    scheduleStartTime = json['schedule_start_time'];
    scheduleEndTime = json['schedule_end_time'];
    latitude = _parseDouble(json['latitude']);
    longitude = _parseDouble(json['longitude']);
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    checkInPhoto = json['check_in_photo'];
    checkOutPhoto = json['check_out_photo'];
    checkoutLatitude = _parseDouble(json['checkout_latitude']);
    checkoutLongitude = _parseDouble(json['checkout_longitude']);
    checkoutStatus = json['checkout_status'];
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
    data['checkout_status'] = this.checkoutStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}