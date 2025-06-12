import 'package:dio/dio.dart';

import '../../../core/constant/api_constant.dart';

class NewsApiService {
  final Dio _dio;

  NewsApiService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.newsBaseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: 5000);
    _dio.options.receiveTimeout = Duration(milliseconds: 3000);

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<NewsResponseModel> getTopHeadlines({
    String country = 'us',
    String? category,
    int page = 1,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'country': country,
        'page': page,
        'pageSize': 20,
        'apiKey': ApiConstants.newsApiKey,
      };

      if (category != null && category.isNotEmpty) {
        queryParameters['category'] = category;
      }

      final response = await _dio.get(
        '/top-headlines',
        queryParameters: queryParameters,
      );

      return NewsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<NewsResponseModel> searchNews({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/everything',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': 20,
          'sortBy': 'relevancy',
          'apiKey': ApiConstants.newsApiKey,
        },
      );

      return NewsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    } else if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['message'] ?? 'Unknown error occurred';

      if (statusCode == 401) {
        return Exception('Authentication failed. Please check your API key.');
      } else if (statusCode == 404) {
        return Exception('The requested data was not found.');
      } else if (statusCode == 429) {
        return Exception('Too many requests. API rate limit exceeded.');
      }
      return Exception('Error $statusCode: $message');
    }
    return Exception('Network error occurred. Please try again.');
  }
}