import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dashboard_page.dart';

class LightPage extends StatelessWidget {
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
            Navigator.pop(context);
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Current Temperature',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '22°C', // Replace with actual data from the cloud
              style: TextStyle(
                color: Colors.orange,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 200, // Set fixed height for rectangle
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: false, // Remove grid lines
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTextStyles: (value) => TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      interval: 5,
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTextStyles: (value) => TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      interval: 4,
                      getTitles: (value) {
                        switch (value.toInt()) {
                          case 0:
                            return '00:00';
                          case 4:
                            return '04:00';
                          case 8:
                            return '08:00';
                          case 12:
                            return '12:00';
                          case 16:
                            return '16:00';
                          case 20:
                            return '20:00';
                          case 24:
                            return '00:00';
                        }
                        return '';
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  minX: 0,
                  maxX: 24,
                  minY: 0,
                  maxY: 40,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 22), // Replace with actual data from the cloud
                        FlSpot(4, 21),
                        FlSpot(8, 23),
                        FlSpot(12, 24),
                        FlSpot(16, 22),
                        FlSpot(20, 21),
                        FlSpot(24, 22),
                      ],
                      isCurved: true,
                      colors: [Colors.orange],
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [Colors.orange.withOpacity(0.3)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

