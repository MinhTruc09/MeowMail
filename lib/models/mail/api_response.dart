class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    if (json['status'] == null) throw Exception('Missing status');
    if (json['message'] == null) throw Exception('Missing message');

    return ApiResponse<T>(
      status: json['status'] as int,
      message: json['message'] as String,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}