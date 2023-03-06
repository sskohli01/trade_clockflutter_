import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Clock',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Digital Clock'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class Tick {
  final int label;
  bool isVisible;
  Tick({required this.label, this.isVisible = true});
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _currentTime = DateTime.now();
  late Timer _timer;
  late List<Tick> _ticks;
  String _formatDateTime(DateTime dateTime, {bool showSecs = false}) {
    if (showSecs) {
      return DateFormat('hh:mm:ss').format(dateTime);
    } else {
      return DateFormat('hh:mm').format(dateTime);
    }
  }

  DateTime _getNextTick(int minutesToAdd) {
    final time = DateTime(_currentTime.year, _currentTime.month,
        _currentTime.day, 9, 15, 0); // Start at 9:15 am
    var nextTick = time.add(Duration(minutes: minutesToAdd));

    while (nextTick.isBefore(time) || nextTick.isBefore(DateTime.now())) {
      nextTick = nextTick.add(Duration(minutes: minutesToAdd));
    }

    if (nextTick.isAfter(DateTime(
        _currentTime.year, _currentTime.month, _currentTime.day, 15, 15, 0))) {
      //ends at 15:15
      //return 'Close at 3:15 pm';
    }
    return nextTick;
    //return DateFormat('hh:mm:ss a').format(nextTick);
  }

  @override
  void initState() {
    super.initState();
    _ticks = [
      Tick(label: 3),
      Tick(label: 5),
      Tick(label: 10),
      Tick(label: 15),
      Tick(label: 30)
    ];
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 80,
              width: 150,
              child: Text(
                _formatDateTime(_currentTime, showSecs: true),
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            const SizedBox(width: 30),
            SizedBox(height: 100, width: 500, child: _tickerList(context)),
          ],
        ),
      ),
    );
  }

  Widget _tickerList(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _ticks.length,
      itemBuilder: (BuildContext context, int index) {
        Tick tick = _ticks[index];
        int tickVal = tick.label;
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Visibility(
                visible: tick.isVisible,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: Column(
                  children: [
                    Text(
                      '$tickVal Min',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildCountdown(_getNextTick(tickVal)),
                  ],
                ),
              ),
              IconButton(
                padding: const EdgeInsets.only(top: 4, right: 4),
                iconSize: 20,
                icon: tick.isVisible
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    tick.isVisible = !tick.isVisible;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCountdown(DateTime nextTick) {
    final now = DateTime.now();
    final diff = nextTick.difference(now);
    final min = diff.inMinutes.remainder(60);
    final sec = diff.inSeconds.remainder(60);

    return SizedBox(
      height: 20,
      width: 90,
      child: Row(
        children: [
          Text(
            _formatDateTime(nextTick),
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '$min:${sec.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 15, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
