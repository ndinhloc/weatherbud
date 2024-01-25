part of 'weather_bloc.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final Position position;
  const FetchWeather({required this.position});
  @override
  List<Object> get props => [];
}

class FecthSearch extends WeatherEvent {
  final String name;
  const FecthSearch({required this.name});
  @override
  List<Object> get props => [];
}
