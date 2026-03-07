class NewsModel {
  final String title;
  final String description;
  final String content;
  final String url;
  final String image;
  final String publishedAt;
  final String sourceName;

  NewsModel({
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.sourceName,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      url: json['url'] ?? '',
      image: json['image'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      sourceName: json['source']['name'] ?? '',
    );
  }
}
