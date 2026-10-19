/// The `pagination` block of a paged list response.
class PaginationModel {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  PaginationModel({this.currentPage, this.lastPage, this.perPage, this.total});

  /// Whether a page after [currentPage] exists.
  bool get hasMore => (currentPage ?? 0) < (lastPage ?? 0);

  PaginationModel copyWith({
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
  }) {
    return PaginationModel(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PaginationSchema.currentPage: currentPage,
      PaginationSchema.lastPage: lastPage,
      PaginationSchema.perPage: perPage,
      PaginationSchema.total: total,
    };
  }

  factory PaginationModel.fromJson(Map<String, dynamic> map) {
    return PaginationModel(
      currentPage: map[PaginationSchema.currentPage]?.toInt(),
      lastPage: map[PaginationSchema.lastPage]?.toInt(),
      perPage: map[PaginationSchema.perPage]?.toInt(),
      total: map[PaginationSchema.total]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationModel &&
        other.currentPage == currentPage &&
        other.lastPage == lastPage &&
        other.perPage == perPage &&
        other.total == total;
  }

  @override
  int get hashCode =>
      currentPage.hashCode ^
      lastPage.hashCode ^
      perPage.hashCode ^
      total.hashCode;
}

class PaginationSchema {
  static const String currentPage = 'current_page';
  static const String lastPage = 'last_page';
  static const String perPage = 'per_page';
  static const String total = 'total';
}
