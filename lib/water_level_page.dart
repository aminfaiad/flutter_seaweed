import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dashboard_page.dart';

class WaterLevelPage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<WaterLevelPage> {
  late TooltipBehavior _tooltipBehavior;
  late TrackballBehavior _trackballBehavior;
  final List<HourTemperature> data = List.generate(
    24,
    (index) => HourTemperature(
      '${index.toString().padLeft(2, '0')}:00',
      (20 + index % 5).toDouble(),
    ),
  );

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: false);
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      lineType: TrackballLineType.vertical,
      builder: (BuildContext context, TrackballDetails details) {
        // Use the pointIndex to get the corresponding data from the source
        final int pointIndex = details.point?.overallDataPointIndex ?? 0;
        final HourTemperature temperatureData = data[pointIndex];
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${temperatureData.hour}',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
              Text(
                '${temperatureData.temperature}°C',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(username: 'User'), // Replace 'User' with actual username
              ),
            );
          },
        ),
        title: Text(
          'Temperature Monitoring',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Temperature',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '22°C', // Replace with live data later
              style: TextStyle(
                color: Colors.orange,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: SfCartesianChart(
                backgroundColor: Colors.black,
                primaryXAxis: CategoryAxis(
                  title: AxisTitle(
                    text: 'Hours',
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  majorGridLines: MajorGridLines(width: 0), // Remove grid lines
                  labelStyle: TextStyle(color: Colors.white),
                ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(
                    text: 'Temperature (°C)',
                    textStyle: TextStyle(color: Colors.white),
                  ),
                  majorGridLines: MajorGridLines(width: 0), // Remove grid lines
                  labelStyle: TextStyle(color: Colors.white),
                  minimum: 15, // Adjust based on data range
                  maximum: 30,
                ),
                tooltipBehavior: _tooltipBehavior,
                trackballBehavior: _trackballBehavior,
                series: <ChartSeries>[
                  SplineSeries<HourTemperature, String>(
                    dataSource: data,
                    xValueMapper: (HourTemperature temp, _) => temp.hour,
                    yValueMapper: (HourTemperature temp, _) => temp.temperature,
                    color: Colors.orange,
                    width: 2,
                    markerSettings: MarkerSettings(
                      height: 10,
                      width: 10,
                      color: Colors.orange,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HourTemperature {
  final String hour;
  final double temperature;

  HourTemperature(this.hour, this.temperature);
}
