import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/datasources/remote/weather_api_service.dart';

enum WeatherStatus {
  initial,
  loading,
  loaded,
  error,
}

class WeatherProvider extends ChangeNotifier {
  final WeatherApiService _apiService = WeatherApiService();
  final WeatherRepositoryImpl _repository = WeatherRepositoryImpl();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _currentWeather;
  ForecastModel? _forecast;
  List<WeatherModel> _savedCities = [];
  String? _errorMessage;

  WeatherStatus get status => _status;
  WeatherModel? get currentWeather => _currentWeather;
  ForecastModel? get forecast => _forecast;
  List<WeatherModel> get savedCities => _savedCities;
  String? get errorMessage => _errorMessage;

  Future<void> getCurrentLocationWeather() async {
    try {
      _status = WeatherStatus.loading;
      notifyListeners();

      // Get current location
      final position = await _determinePosition();

      // Fetch current weather
      _currentWeather = await _apiService.getCurrentWeather(
          position.latitude,
          position.longitude
      );

      // Fetch forecast
      _forecast = await _apiService.getForecast(
          position.latitude,
          position.longitude
      );

      // Save data to local storage
      await _repository.cacheWeatherData(_currentWeather!);
      await _repository.cacheForecastData(_forecast!);

      _status = WeatherStatus.loaded;
    } catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.toString();

      // Try to load cached data
      try {
        _currentWeather = await _repository.getCachedWeatherData();
        _forecast = await _repository.getCachedForecastData();
      } catch (e) {
        // If no cached data available, leave as null
      }
    }
    notifyListeners();
  }

  Future<void> getWeatherByCity(String cityName) async {
    try {
      _status = WeatherStatus.loading;
      notifyListeners();

      final weather = await _apiService.getWeatherByCity(cityName);

      // Add to saved cities if not already there
      if (!_savedCities.any((city) => city.cityId == weather.cityId)) {
        _savedCities.add(weather);
        await _repository.saveCityToFavorites(weather);
      }

      _status = WeatherStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> loadSavedCities() async {
    try {
      _savedCities = await _repository.getFavoriteCities();
    } catch (e) {
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> removeSavedCity(int cityId) async {
    _savedCities.removeWhere((city) => city.cityId == cityId);
    await _repository.removeCityFromFavorites(cityId);
    notifyListeners();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }
}