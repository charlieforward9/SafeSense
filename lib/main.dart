import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MyHomePage(title: 'SafeSense'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const countdownDuration = Duration(seconds: 30);

  var seconds = 30;
  Duration duration = const Duration(seconds: 30);
  Timer? timer;
  bool hasFallen = false;
  bool isCountDown = true;
  bool contactAuthorities = false;
  late final AudioCache _audioCache;

  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(
      prefix: 'assets/audio/',
      fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP),
    );
  }

  void startTimer() {
    setState(() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => decrement());
    });
  }

  void decrement() {
    setState(() {
      if (isCountDown) {
        seconds = duration.inSeconds - 1;
        print('Duration: $seconds');
        if (seconds < 0) {
          confirmedFall();
        } else {
          duration = Duration(seconds: seconds);
        }
      }
    });
  }

  void resetTimer() {
    timer?.cancel();
    duration = countdownDuration;
  }

  void resetApp() {
    setState(() {
      hasFallen = false;
      isCountDown = true;
      contactAuthorities = false;
      resetTimer();
      _audioCache.play("alarm.mp3", volume: 0);
    });
  }

  //Function used when accelerometer data indicates possibility of fall.
  //Proceeds to prompt user if a fall occurred.
  void fallTrigger() {
    setState(() {
      hasFallen = true;

      startTimer();
    });
  }

  void confirmedFall() {
    setState(() {
      contactAuthorities = true;
      isCountDown = false;
      hasFallen = true;
      resetTimer();
    });
  }

  void makeNoise() {
    _audioCache.play('alarm.mp3', volume: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Visibility(
                  child: const Text("No fall detected \n Enjoy yourself!",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                  visible: !hasFallen),
              Visibility(
                child: const Text('Fall detected \n Are you OK?',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
                visible: (hasFallen & !contactAuthorities),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      child: ElevatedButton(
                          child: const Text("Yes",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50)),
                          onPressed: resetApp,
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.green),
                              shadowColor: MaterialStateProperty.all<Color>(
                                Colors.green.withOpacity(0.5),
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                  const Size(180, 400)))),
                      visible: (hasFallen & !contactAuthorities)),
                  const SizedBox(
                    width: 9,
                  ),
                  Visibility(
                    child: ElevatedButton(
                        child: const Text("No",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 50)),
                        onPressed: confirmedFall,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shadowColor: MaterialStateProperty.all<Color>(
                                Colors.red.withOpacity(0.5)),
                            fixedSize: MaterialStateProperty.all<Size>(
                                const Size(180, 400)))),
                    visible: (hasFallen & !contactAuthorities),
                  )
                ],
              ),
              Visibility(
                  child: const Text(
                    'Contacting help in...',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                  visible: (hasFallen & !contactAuthorities)),
              Visibility(
                  child: buildTime(),
                  visible: (hasFallen & !contactAuthorities)),
              Visibility(
                  child: const Text('Help is on the way',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  visible: contactAuthorities),
              Visibility(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                      child: ElevatedButton(
                          child: const Text("Noise",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50)),
                          onPressed: makeNoise,
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              shadowColor: MaterialStateProperty.all<Color>(
                                Colors.green.withOpacity(0.5),
                              ),
                              fixedSize: MaterialStateProperty.all<Size>(
                                  const Size(180, 400)))),
                      visible: (contactAuthorities)),
                  const SizedBox(
                    width: 9,
                  ),
                  Visibility(
                    child: ElevatedButton(
                        child: const Text("Reset",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                            )),
                        onPressed: resetApp,
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.red),
                            shadowColor: MaterialStateProperty.all<Color>(
                                Colors.red.withOpacity(0.5)),
                            fixedSize: MaterialStateProperty.all<Size>(
                                const Size(180, 400)))),
                    visible: (contactAuthorities),
                  )
                ],
              )),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (!contactAuthorities & !hasFallen) {
                  fallTrigger();
                } else {
                  print("RESET APP REQUIRED");
                }
              },
              tooltip: 'Trigger Fall',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: resetApp,
              tooltip: 'Reset',
              child: const Icon(Icons.loop),
            )
          ],
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  Widget buildTime() {
    return Text('${duration.inSeconds}', style: const TextStyle(fontSize: 40));
  }
}
