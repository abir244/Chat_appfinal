import 'dart:convert';
import 'package:chat_app/core/constants/app_constants.dart';
import 'package:chat_app/data/models/news_model.dart';
import 'package:http/http.dart' as http;

abstract class INewsRepository {
  Future<List<NewsModel>> getTopNews();
}

class NewsRepository implements INewsRepository {
  @override
  Future<List<NewsModel>> getTopNews() async {
    final url = Uri.parse(
      'https://gnews.io/api/v4/top-headlines?category=general&lang=en&apikey=${AppConstants.gNewsApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List articles = data['articles'];
      return articles.map((article) => NewsModel.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news: ${response.statusCode}');
    }
  }
}
