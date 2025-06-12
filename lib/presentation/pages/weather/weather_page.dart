import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_news_dashboard/presentation/providers/weather_provider.dart';
import 'package:weather_news_dashboard/presentation/widgets/weather/current_weather_widget.dart';
import 'package:weather_news_dashboard/presentation/widgets/weather/forecast_widget.dart';
import 'package:weather_news_dashboard/presentation/widgets/weather/city_search_widget.dart';
import 'package:weather_news_dashboard/presentation/widgets/weather/saved_cities_widget.dart';
import 'package:weather_news_dashboard/presentation/widgets/common/error_widget.dart';
import '../../provider/weather_provider.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      weatherProvider.getCurrentLocationWeather();
      weatherProvider.loadSavedCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showCitySearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              Provider.of<WeatherProvider>(context, listen: false)
                  .getCurrentLocationWeather();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<WeatherProvider>(context, listen: false)
              .getCurrentLocationWeather();
        },
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final status = weatherProvider.status;

        if (status == WeatherStatus.initial) {
          return Center(child: Text('Search for a city or enable location services'));
        }

        if (status == WeatherStatus.loading && weatherProvider.currentWeather == null) {
          return Center(child: CircularProgressIndicator());
        }

        if (status == WeatherStatus.error && weatherProvider.currentWeather == null) {
          return AppErrorWidget(
            message: weatherProvider.errorMessage ?? 'An error occurred',
            onRetry: () => weatherProvider.getCurrentLocationWeather(),
          );
        }

        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (weatherProvider.currentWeather != null)
                CurrentWeatherWidget(weather: weatherProvider.currentWeather!),
              SizedBox(height: 16),
              if (weatherProvider.forecast != null)
                ForecastWidget(forecast: weatherProvider.forecast!),
              SizedBox(height: 16),
              Text(
                'Saved Cities',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              SavedCitiesWidget(
                savedCities: weatherProvider.savedCities,
                onRemove: (cityId) => weatherProvider.removeSavedCity(cityId),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCitySearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CitySearchWidget(
        onCitySelected: (city) {
          Provider.of<WeatherProvider>(context, listen: false)
              .getWeatherByCity(city);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}