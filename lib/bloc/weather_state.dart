part of 'weather_bloc.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

final class WeatherInitial extends WeatherState {}

final class WeatherLoading extends WeatherState {}

final class WeatherFetchSuccess extends WeatherState {
  final List<Weather> weather;
  const WeatherFetchSuccess(this.weather);
}

final class WeatherFetchFailed extends WeatherState {}
