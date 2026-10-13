import 'package:dio/dio.dart';

import '../../../../core/config/env.dart';
import '../../../../core/error/app_exception.dart';
import '../models/pixabay_image.dart';

class PixabayRemoteDataSource {
  PixabayRemoteDataSource(this._dio);
  final Dio _dio;

  Future<PagedImages> fetch({
    required String query,
    String? category,
    required int page,
    required int perPage,
  }) async {
    if (!Env.hasApiKey) throw const ApiKeyMissingException();

    final params = <String, dynamic>{
      'key': Env.pixabayApiKey,
      'image_type': 'photo',
      'safesearch': true,
      'page': page,
      'per_page': perPage,
      if (query.isNotEmpty) 'q': query,
      if (category != null) 'category': category,
    };

    try {
      final res = await _dio.get<Map<String, dynamic>>('', queryParameters: params);
      final data = res.data ?? const <String, dynamic>{};
      final hits = (data['hits'] as List? ?? const [])
          .map((e) => PixabayImage.fromJson(e as Map<String, dynamic>))
          .toList();
      return PagedImages(
        images: hits,
        totalHits: (data['totalHits'] as num?)?.toInt() ?? hits.length,
      );
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          throw const NetworkException();
        default:
          final code = e.response?.statusCode;
          if (code == 429) {
            throw const ServerException(
                'Rate limit reached. Please wait a minute and retry.');
          }
          if (code == 400) {
            throw const ServerException('Invalid request or API key.');
          }
          throw ServerException('Server error${code != null ? ' ($code)' : ''}.');
      }
    }
  }
}