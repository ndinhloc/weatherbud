import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';

part 'weather_event.dart';
part 'weather_state.dart';

WeatherFactory wf = WeatherFactory('d97faffa088322fdf681c1f4964beb9d');

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<FetchWeather>((event, emit) async {
      emit(WeatherLoading());
      try {
        List<Weather> weather = await wf.fiveDayForecastByLocation(
            event.position.latitude, event.position.longitude);
        print(weather.length);
        emit(WeatherFetchSuccess(weather));
      } catch (e) {
        print(e);
        emit(WeatherFetchFailed());
      }
      // TODO: implement event handler
    });
    on<FecthSearch>(
      (event, emit) async {
        emit(WeatherLoading());
        try {
          List<Weather> weather =
              await wf.fiveDayForecastByCityName(event.name);

          emit(WeatherFetchSuccess(weather));
        } catch (e) {
          print(e);
          emit(WeatherFetchFailed());
        }
      },
    );
  }
}
