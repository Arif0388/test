class UploadedFileModel {
  final String key;
  final String originalname;
  final String mimetype;
  final int size;
  final String location;

  UploadedFileModel({
    required this.key,
    required this.originalname,
    required this.mimetype,
    required this.size,
    required this.location,
  });

  factory UploadedFileModel.fromJson(Map<String, dynamic> json) {
    return UploadedFileModel(
      key: json['key'],
      originalname: json['originalname'],
      mimetype: json['mimetype'],
      size: json['size'],
      location: json['location'],
    );
  }
}
