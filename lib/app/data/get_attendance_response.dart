class GetAttendanceResponse {
  String? status;
  String? pesan;
  Data? data;

  GetAttendanceResponse({this.status, this.pesan, this.data});

  GetAttendanceResponse.fromJson(Map<String, dynamic> json) {
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
  String? startTime;
  String? endTime;
  String? status;
  String? endTimeStatus;
  String? checkInPhoto;
  String? checkOutPhoto;

  HariIni(
      {this.startTime,
      this.endTime,
      this.status,
      this.endTimeStatus,
      this.checkInPhoto,
      this.checkOutPhoto});

  HariIni.fromJson(Map<String, dynamic> json) {
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    endTimeStatus = json['end_time_status'];
    checkInPhoto = json['check_in_photo'];
    checkOutPhoto = json['check_out_photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;
    data['status'] = this.status;
    data['end_time_status'] = this.endTimeStatus;
    data['check_in_photo'] = this.checkInPhoto;
    data['check_out_photo'] = this.checkOutPhoto;
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

  BulanIni(
      {this.tanggal,
      this.jamMasuk,
      this.jamPulang,
      this.statusMasuk,
      this.statusPulang,
      this.fotoMasuk,
      this.fotoPulang});

  BulanIni.fromJson(Map<String, dynamic> json) {
    tanggal = json['tanggal'];
    jamMasuk = json['jam_masuk'];
    jamPulang = json['jam_pulang'];
    statusMasuk = json['status_masuk'];
    statusPulang = json['status_pulang'];
    fotoMasuk = json['foto_masuk'];
    fotoPulang = json['foto_pulang'];
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
    return data;
  }
}
