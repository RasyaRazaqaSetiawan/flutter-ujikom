class GetAttendanceResponse {
  String? status;
  String? message;
  Data? data;

  GetAttendanceResponse({this.status, this.message, this.data});

  GetAttendanceResponse.fromJson(Map<String, dynamic> json) {
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
  HariIni? hariIni;
  List<BulanIni>? bulanIni;

  Data({this.hariIni, this.bulanIni});

  Data.fromJson(Map<String, dynamic> json) {
    hariIni = json['hari_ini'] != null
        ? new HariIni.fromJson(json['hari_ini'])
        : null;
    if (json['bulan_ini'] != null) {
      bulanIni = <BulanIni>[];
      json['bulan_ini'].forEach((v) {
        bulanIni!.add(new BulanIni.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.hariIni != null) {
      data['hari_ini'] = this.hariIni!.toJson();
    }
    if (this.bulanIni != null) {
      data['bulan_ini'] = this.bulanIni!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HariIni {
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
  String? officeName;
  String? shiftName;

  HariIni(
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
      this.updatedAt,
      this.officeName,
      this.shiftName});

  HariIni.fromJson(Map<String, dynamic> json) {
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
    checkoutStatus = json['checkout_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    officeName = json['office_name'];
    shiftName = json['shift_name'];
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
    data['office_name'] = this.officeName;
    data['shift_name'] = this.shiftName;
    return data;
  }
}

class BulanIni {
  String? tanggal;
  String? jamMasuk;
  String? jamPulang;
  String? statusMasuk;
  String? statusPulang;
  String? fotoMasuk;
  String? fotoPulang;
  String? kantor;
  String? shift;

  BulanIni(
      {this.tanggal,
      this.jamMasuk,
      this.jamPulang,
      this.statusMasuk,
      this.statusPulang,
      this.fotoMasuk,
      this.fotoPulang,
      this.kantor,
      this.shift});

  BulanIni.fromJson(Map<String, dynamic> json) {
    tanggal = json['tanggal'];
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
    statusMasuk = json['status_masuk'];
    statusPulang = json['status_pulang'];
    fotoMasuk = json['foto_masuk'];
    fotoPulang = json['foto_pulang'];
    kantor = json['kantor'];
    shift = json['shift'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tanggal'] = this.tanggal;
    data['jam_masuk'] = this.jamMasuk;
    data['jam_pulang'] = this.jamPulang;
    data['status_masuk'] = this.statusMasuk;
    data['status_pulang'] = this.statusPulang;
    data['foto_masuk'] = this.fotoMasuk;
    data['foto_pulang'] = this.fotoPulang;
    data['kantor'] = this.kantor;
    data['shift'] = this.shift;
    return data;
  }
}
