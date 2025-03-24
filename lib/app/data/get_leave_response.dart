class get_leave_respones {
  bool? success;
  List<Data>? data;
  String? message;

  get_leave_respones({this.success, this.data, this.message});

  get_leave_respones.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? categoriesLeave;
  String? startDate;
  String? endDate;
  String? reason;
  String? status;
  String? scheduleOffice;
  String? attachment;
  String? createdAt;
  String? updatedAt;
  int? days;
  String? formattedDates;
  String? attachmentUrl;

  Data(
      {this.id,
      this.userId,
      this.categoriesLeave,
      this.startDate,
      this.endDate,
      this.reason,
      this.status,
      this.scheduleOffice,
      this.attachment,
      this.createdAt,
      this.updatedAt,
      this.days,
      this.formattedDates,
      this.attachmentUrl});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    categoriesLeave = json['categories_leave'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    reason = json['reason'];
    status = json['status'];
    scheduleOffice = json['schedule_office'];
    attachment = json['attachment'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    days = json['days'];
    formattedDates = json['formatted_dates'];
    attachmentUrl = json['attachment_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['categories_leave'] = this.categoriesLeave;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['schedule_office'] = this.scheduleOffice;
    data['attachment'] = this.attachment;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['days'] = this.days;
    data['formatted_dates'] = this.formattedDates;
    data['attachment_url'] = this.attachmentUrl;
    return data;
  }
}
