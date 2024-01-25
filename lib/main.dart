import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherbud/bloc/weather_bloc.dart';
import 'package:weatherbud/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightBlue[800],
          fontFamily: 'Georgia',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic),
          )),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
          future: determinePosition(),
          builder: (context, snap) {
            if (snap.hasData) {
              return BlocProvider<WeatherBloc>(
                create: (context) => WeatherBloc()
                  ..add(FetchWeather(position: snap.data as Position)),
                child: const CustomDrawer(),
              );
            } else {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
          }),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with TickerProviderStateMixin {
  AnimationController? drawerAnimationController;
  AnimationController? waveAnimationController;
  var _tabTextIndexSelected = 0;
  TextEditingController searchController = TextEditingController();
  Widget getWeatherIcon(int code) {
    switch (code) {
      case >= 200 && < 300:
        return Image.asset('assets/icons/thunder.png');
      case >= 300 && < 400:
        return Image.asset('assets/icons/rainy.png');
      case >= 500 && < 600:
        return Image.asset('assets/icons/heavy-rain.png');
      case >= 600 && < 700:
        return Image.asset('assets/icons/snow.png');
      case 800:
        return Image.asset('assets/icons/sunny.png');
      case > 800 && <= 804:
        return Image.asset('assets/icons/cloudy.png');
      default:
        return Image.asset('assets/icons/sunny.png');
    }
  }

  @override
  void initState() {
    super.initState();
    drawerAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      upperBound: 1,
      lowerBound: -1,
      value: 0.0,
    )..repeat(reverse: true);
  }

  void toggle() => drawerAnimationController!.isDismissed
      ? drawerAnimationController!.forward()
      : drawerAnimationController!.reverse();

  @override
  Widget build(BuildContext context) {
    const double maxSlide = 295;
    Size screenSize = MediaQuery.of(context).size;
    final weatherBloc = BlocProvider.of<WeatherBloc>(context);
    var drawer = Scaffold(
      backgroundColor: const Color.fromARGB(255, 160, 147, 253),
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.sizeOf(context).width * 0.6,
          height: 50,
          child: TextField(
            controller: searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
                fillColor: Color.fromARGB(255, 255, 254, 250),
                filled: true,
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                hintText: "Search by city...",
                hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                    },
                    icon: const Icon(Icons.clear))),
            onSubmitted: (value) {
              weatherBloc.add(FecthSearch(name: value));
              searchController.clear();
              toggle();
            },
          ),
        ),
      ),
    );

    var child = BlocBuilder<WeatherBloc, WeatherState>(
      builder: (context, state) {
        if (state is WeatherFetchSuccess) {
          return Container(
            decoration: const BoxDecoration(boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(-10, 10),
                blurRadius: 20.0,
                spreadRadius: 5.0,
              )
            ]),
            child: ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(20)),
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 107, 86, 253),
                  Color.fromARGB(255, 192, 182, 255),
                ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    title: Text(
                      state.weather.first.areaName!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    centerTitle: true,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.search_outlined,
                        color: Colors.white70,
                      ),
                      onPressed: () => toggle(),
                    ),
                    actions: [
                      IconButton(
                          icon: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white70,
                          ),
                          onPressed: () async {
                            var pos = await determinePosition();
                            BlocProvider.of<WeatherBloc>(context)
                                .add(FetchWeather(position: pos));
                          }),
                    ],
                  ),
                  body: Stack(
                    children: [
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${state.weather.first.temperature!.toString().split('.').first}°C",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 54),
                            ),
                            SizedBox(
                                height: 200,
                                width: 200,
                                child: getWeatherIcon(
                                    state.weather.first.weatherConditionCode!)),
                            Padding(
                              padding: const EdgeInsets.only(top: 18),
                              child: Text(
                                state.weather.first.weatherMain!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 32),
                              ),
                            ),
                            Text(
                              DateFormat('EEEE dd •')
                                  .add_jm()
                                  .format(state.weather.first.date!),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Stack(
                          children: [
                            AnimatedBuilder(
                              animation: waveAnimationController!,
                              builder: (BuildContext context, Widget? child) {
                                return ClipPath(
                                  clipper: WaveClipMain(
                                      waveAnimationController!.value * 25,
                                      1 / 4,
                                      1 / 2,
                                      1 / 2,
                                      -1 / 10,
                                      200,
                                      20),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.45,
                                    decoration:
                                        const BoxDecoration(color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: waveAnimationController!,
                              builder: (BuildContext context, Widget? child) {
                                return ClipPath(
                                  clipper: WaveClipMain(
                                      waveAnimationController!.value * 2,
                                      1 / 8,
                                      -1 / 10000,
                                      5 / 8,
                                      -1 / 10,
                                      100,
                                      50),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.45,
                                    decoration: BoxDecoration(
                                        color:
                                            Colors.grey[400]!.withAlpha(220)),
                                  ),
                                );
                              },
                            ),
                            AnimatedBuilder(
                              animation: waveAnimationController!,
                              builder: (BuildContext context, Widget? child) {
                                return ClipPath(
                                  clipper: WaveClipMain(
                                      waveAnimationController!.value * 10,
                                      1 / 4,
                                      1 / 4,
                                      3 / 4,
                                      -1 / 10,
                                      40,
                                      100),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.45,
                                    decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 245, 237, 255)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 100),
                                      child: Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: FlutterToggleTab(
                                                width: 40, // width in percent
                                                borderRadius: 40,
                                                height: 40,
                                                selectedIndex:
                                                    _tabTextIndexSelected,
                                                selectedBackgroundColors: [
                                                  Color.fromARGB(
                                                      255, 107, 86, 253),
                                                  Colors.blueAccent
                                                ],
                                                selectedTextStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                unSelectedTextStyle: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                labels: ['Today', '5 Days'],
                                                selectedLabelIndex: (index) {
                                                  setState(() {
                                                    _tabTextIndexSelected =
                                                        index;
                                                  });
                                                },
                                                isScroll: false,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 40,
                                          ),
                                          if (_tabTextIndexSelected == 0)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                for (int i = 0; i <= 4; i++)
                                                  if (i == 0)
                                                    getForecastCard(
                                                        screenSize,
                                                        state.weather[i]
                                                            .temperature
                                                            .toString(),
                                                        "Now".toString(),
                                                        state.weather[i]
                                                            .weatherConditionCode!)
                                                  else
                                                    getForecastCard(
                                                        screenSize,
                                                        state.weather[i]
                                                            .temperature
                                                            .toString(),
                                                        DateFormat.jm()
                                                            .format(state
                                                                .weather[i]
                                                                .date!)
                                                            .toString(),
                                                        state.weather[i]
                                                            .weatherConditionCode!)
                                              ],
                                            )
                                          else
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                for (int i = 0; i < 40; i += 8)
                                                  if (i == 0)
                                                    getForecastCard(
                                                        screenSize,
                                                        state.weather[i]
                                                            .temperature
                                                            .toString(),
                                                        "Today",
                                                        state.weather[i]
                                                            .weatherConditionCode!)
                                                  else
                                                    getForecastCard(
                                                        screenSize,
                                                        state.weather[i]
                                                            .temperature
                                                            .toString(),
                                                        DateFormat.EEEE()
                                                            .format(state
                                                                .weather[i]
                                                                .date!)
                                                            .toString(),
                                                        state.weather[i]
                                                            .weatherConditionCode!)
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is WeatherFetchFailed) {
          return Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  offset: Offset(-10, 10),
                  blurRadius: 20.0,
                  spreadRadius: 5.0,
                )
              ]),
              child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(20)),
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                        Color.fromARGB(255, 107, 86, 253),
                        Color.fromARGB(255, 192, 182, 255),
                      ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          leading: IconButton(
                            icon: const Icon(
                              Icons.search_outlined,
                              color: Colors.white70,
                            ),
                            onPressed: () => toggle(),
                          ),
                          actions: [
                            IconButton(
                                icon: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white70,
                                ),
                                onPressed: () async {
                                  var pos = await determinePosition();
                                  BlocProvider.of<WeatherBloc>(context)
                                      .add(FetchWeather(position: pos));
                                }),
                          ],
                        ),
                        body: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                                color: Color.fromARGB(255, 250, 212, 216),
                                borderRadius: BorderRadius.circular(30)),
                            child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    "Sorry, ivalid city name.",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 24,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  Icon(
                                    Icons.error_outline_sharp,
                                    size: 54,
                                    color: Colors.redAccent,
                                  ),
                                  Text(
                                    "Please try again.",
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 24,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  )
                                ]),
                          ),
                        ),
                      ))));
        } else {
          return Container();
        }
      },
    );
    return AnimatedBuilder(
      builder: (context, _) {
        double slide = maxSlide * drawerAnimationController!.value;
        double scale = 1 - (drawerAnimationController!.value * 0.4);
        return Stack(
          children: <Widget>[
            drawer,
            Transform(
              transform: Matrix4.identity()
                ..translate(slide)
                ..scale(scale),
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ],
        );
      },
      animation: drawerAnimationController!,
    );
  }

  Widget getForecastCard(
      Size screenSize, String temperature, String time, int code) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Color.fromARGB(255, 224, 223, 240),
                blurRadius: 5,
                offset: Offset(-4, 8))
          ],
          color: const Color(0xFFF6F5FF)),
      child: Column(
        children: [
          Text(time),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            height: screenSize.width / 5 - 20,
            width: screenSize.width / 5 - 20,
            child: getWeatherIcon(code),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "${temperature.split('.').first}°C",
          )
        ],
      ),
    );
  }
}

class WaveClipMain extends CustomClipper<Path> {
  double controllValue = 0;
  WaveClipMain(this.controllValue, this.cubicParam1, this.cubicParam2,
      this.cubicParam3, this.cubicParam4, this.desY1, this.desY2);
  double cubicParam1 = 0;
  double cubicParam2 = 0;
  double cubicParam3 = 0;
  double cubicParam4 = 0;
  double desY1 = 0;
  double desY2 = 0;
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    var path = Path();
    path.moveTo(0, height);
    path.lineTo(0, desY1);

    path.cubicTo(
        width * cubicParam1 + controllValue,
        height * cubicParam2 + controllValue,
        width * cubicParam3 + controllValue,
        height * cubicParam4 + controllValue,
        width,
        desY2);
    path.lineTo(width, height);
    path.close();

    // path.lineTo(0, height - 50);
    // path.quadraticBezierTo(width / 2, height, width, height - 50);
    // path.lineTo(width, 0);
    // path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
