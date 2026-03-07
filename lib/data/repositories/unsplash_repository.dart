import 'dart:convert';
import 'package:chat_app/core/constants/app_constants.dart';
import 'package:chat_app/data/models/unsplash_model.dart';
import 'package:http/http.dart' as http;

abstract class IUnsplashRepository {
  Future<List<UnsplashModel>> getTravelPhotos();
}

class UnsplashRepository implements IUnsplashRepository {
  @override
  Future<List<UnsplashModel>> getTravelPhotos() async {
    final url = Uri.parse(
      'https://api.unsplash.com/photos/random?query=travel&count=20&client_id=${AppConstants.unsplashAccessKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((photo) => UnsplashModel.fromJson(photo)).toList();
    } else {
      throw Exception('Failed to load photos: ${response.statusCode}');
    }
  }
}
