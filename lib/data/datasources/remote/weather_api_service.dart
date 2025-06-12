import 'package:dio/dio.dart';
import '../../../core/constant/api_constant.dart';

class WeatherApiService {
  final Dio _dio;

  WeatherApiService() : _dio = Dio() {
    _dio.options.baseUrl = ApiConstants.weatherBaseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: 5000);
    _dio.options.receiveTimeout = Duration(milliseconds: 3000);

    // Add interceptors for logging, error handling, etc.
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<WeatherModel> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': 'metric',
          'appid': ApiConstants.weatherApiKey,
        },
      );
      return WeatherModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ForecastModel> getForecast(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/forecast',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'units': 'metric',
          'appid': ApiConstants.weatherApiKey,
        },
      );
      return ForecastModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<WeatherModel> getWeatherByCity(String cityName) async {
    try {
      final response = await _dio.get(
        '/weather',
        queryParameters: {
          'q': cityName,
          'units': 'metric',
          'appid': ApiConstants.weatherApiKey,
        },
      );
      return WeatherModel.fromJson(response.data);
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