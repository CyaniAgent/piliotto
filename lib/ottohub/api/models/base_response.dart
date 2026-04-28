class BaseResponse<T> {
  final String status;
  final T? data;
  final String? message;

  BaseResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      status: json['status'] ?? '',
      data: json['data'],
      message: json['message'],
    );
  }
}

class ListResponse<T> {
  final List<T> list;
  final int? total;
  final int? totalPages;
  final int? page;
  final int? limit;

  ListResponse({
    required this.list,
    this.total,
    this.totalPages,
    this.page,
    this.limit,
  });
}
