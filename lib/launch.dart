import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:vector_math/vector_math.dart';

// The object that represents the cannon ball at a state of time
class BallPosition {
  final double x;
  final double y;
  final int radius; // Just for fun

  BallPosition(this.x, this.y, this.radius);
}

class LaunchScreen extends StatefulWidget {
  @override
  _LaunchScreenState createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  // Unique ID to represent the form
  final _formKey = GlobalKey<FormState>();

  final angleController = TextEditingController();
  final speedController = TextEditingController();
  final radiusOfBall = TextEditingController();

  var isGenerating = false; // Are we currently generating values?
  List<BallPosition> data = []; // Data in the graph

  // Get the data on the graph
  List<charts.Series<BallPosition, double>> _createData() {
    // Generate the graph and all the formatting stuff
    return [
      new charts.Series<BallPosition, double>(
        id: 'Position of Cannon Ball',
        colorFn: (BallPosition pos, _) {
          // If the x position isn't the latest one, lighten the color
          return pos.x == data[data.length - 1].x ?
            charts.Color(r: 112, g: 160, b: 255) :
            charts.Color(r: 161, g: 183, b: 255);
        },
        domainFn: (BallPosition pos, _) => pos.x,
        // x = domain
        measureFn: (BallPosition pos, _) => pos.y,
        // u = range
        radiusPxFn: (BallPosition pos, _) => pos.radius,
        // Radius
        data: data, // Actual data
      )
    ];
  }

  double sinSq(double d) {
    return (1 - cos(2 * d)) / 2;
  }

  double cosSq(double d) {
    return (1 + cos(2 * d)) / 2;
  }

  // Checks if a strange is numeric. Used for form validation
  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }

    return double.parse(s, (e) => null) != null ||
        int.parse(s, onError: (e) => null) != null;
  }

  startGenerating(
      double angle,
      double speed,
      double radius,
      BuildContext context) {
    // Make sure we arent already generating;
    if (isGenerating) {
      print('gene');
      return;
    }

    isGenerating = true;
    double t = 0.0;

    const time = const Duration(milliseconds: 100);
    new Timer.periodic(time, (Timer timer) {
      setState(() {
        var y = (speed * t * sin(angle)) - ((0.5 * (9.8 + ((0.8601843 * pow(speed, 2) * sinSq(angle))) / pow(radius, 2))) * pow(t, 2));
        var x = (speed * t * cos(angle)) - ((0.5 * 0.8601843) * ((speed * cosSq(angle)) / pow(radius, 2)) * pow(t, 2));

        // Check if the y dips below 0
        if (y <= 0 && t != 0) {
          timer.cancel();
          isGenerating = false;

          // Generate an invisible point to set the size
          setState(() {
            data.add(BallPosition(0, data[data.length - 1].x, 0));
          });

          return;
        }

        data.add(BallPosition(x, y, 10)); // Append the wait to rerun
        t += 0.05; // Increment 1 by 0.1
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Launch Cannon'),
      ),
      body: Column(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // Angle
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Angle (degrees)',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (!isNumeric(value)) {
                              return 'Must be a number';
                            }
                            return null;
                          },
                          controller: this.angleController,
                        ),
                      ),
                      // Speed
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Speed (m/s)',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (!isNumeric(value)) {
                              return 'Must be a number';
                            }
                            return null;
                          },
                          controller: this.speedController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Radius of cannon ball
                  TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Radius Of Cannon Ball (cm)',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      } else if (!isNumeric(value)) {
                        return 'Must be a number';
                      }
                      return null;
                    },
                    controller: this.radiusOfBall,
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        startGenerating(
                            radians(double.parse(angleController.text)),
                            double.parse(speedController.text),
                            double.parse(radiusOfBall.text),
                          context,
                        );
                      }
                    },
                    child: Text("Fire Cannon Ball! 🚀"),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            // Expanded because we're using the remaining room
            // The actual graph here
            child: Container(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 40),
              child: new charts.ScatterPlotChart(
                  _createData(),
                  animate: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
