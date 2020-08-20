/// Demo of using the oscilloscope package
///
/// In this demo 2 displays are generated showing the outputs for Sine & Cosine
/// The scope displays will show the data sets  which will fill the yAxis and then the screen display will 'scroll'
import 'package:flutter/material.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'dart:typed_data' show Float64List;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Oscilloscope Display Example",
      home: Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  @override
  _ShellState createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<double> traceSine = List();
  List<double> traceCosine = List();
  FlutterAudioCapture _plugin = new FlutterAudioCapture();
  double radians = 0.0;
  Timer _timer;


  void listener(dynamic obj) {
    setState(() {
      traceSine = Float64List.fromList(obj.cast<double>()).toList(growable: true);
    });

    print(traceSine);
  }

  /// method to generate a Test  Wave Pattern Sets
  /// this gives us a value between +1  & -1 for sine & cosine
  _generateTrace(Timer t) {
    // generate our  values
    var sv = sin((radians * pi));
    var cv = cos((radians * pi));

    // Add to the growing dataset
    setState(() {
      traceSine.add(sv);
      traceCosine.add(cv);
    });

    // adjust to recyle the radian value ( as 0 = 2Pi RADS)
    radians += 0.05;
    if (radians >= 2.0) {
      radians = 0.0;
    }
  }

  @override
  initState() {
    super.initState();
    _startCapture();

    // create our timer to generate test values
    //_timer = Timer.periodic(Duration(milliseconds: 60), _generateTrace);

  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _startCapture() async {
    await _plugin.start(listener, null, sampleRate: 16000, bufferSize: 3000);
  }

  @override
  Widget build(BuildContext context) {

    // Create A Scope Display for Sine
    Oscilloscope scopeOne = Oscilloscope(
      showYAxis: true,
      yAxisColor: Colors.orange,
      padding: 20.0,
      backgroundColor: Colors.black,
      traceColor: Colors.green,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: traceSine,
    );

    // Create A Scope Display for Cosine
    Oscilloscope scopeTwo = Oscilloscope(
      showYAxis: true,
      padding: 20.0,
      backgroundColor: Colors.black,
      traceColor: Colors.yellow,
      yAxisMax: 1.0,
      yAxisMin: -1.0,
      dataSet: traceCosine,
    );

    // Generate the Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Text("OscilloScope Demo"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 1, child: scopeOne),
          Expanded(
            flex: 1,
            child: scopeTwo,
          ),
        ],
      ),
    );
  }
}
