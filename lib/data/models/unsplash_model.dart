class UnsplashModel {
  final String id;
  final String description;
  final String url;
  final String thumb;
  final String userName;
  final String userProfileUrl;

  UnsplashModel({
    required this.id,
    required this.description,
    required this.url,
    required this.thumb,
    required this.userName,
    required this.userProfileUrl,
  });

  factory UnsplashModel.fromJson(Map<String, dynamic> json) {
    return UnsplashModel(
      id: json['id'],
      description: json['description'] ?? json['alt_description'] ?? 'No description',
      url: json['urls']['regular'],
      thumb: json['urls']['small'],
      userName: json['user']['name'],
      userProfileUrl: json['user']['links']['html'],
    );
  }
}
