class FileUploadResponse {
  final String fileUrl;

  FileUploadResponse({
    required this.fileUrl,
  });

  factory FileUploadResponse.fromJson(String fileUrl) {
    return FileUploadResponse(
      fileUrl: fileUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileUrl': fileUrl,
    };
  }
}
