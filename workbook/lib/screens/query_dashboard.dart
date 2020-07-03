import 'package:flutter/material.dart';
import 'package:multi_charts/multi_charts.dart';

class QueryDashboard extends StatefulWidget {
  final double registered;
  final double unRegistered;
  final double total;

  const QueryDashboard(
      {Key key, this.registered, this.unRegistered, this.total})
      : super(key: key);

  @override
  _QueryDashboardState createState() => _QueryDashboardState();
}

class _QueryDashboardState extends State<QueryDashboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: PieChart(
          legendTextSize: 14,
          sliceFillColors: [Colors.tealAccent, Colors.red, Colors.cyan],
          legendItemPadding: EdgeInsets.all(8),
          legendIconShape: LegendIconShape.Circle,
          size: Size(MediaQuery.of(context).size.height * 0.3,
              MediaQuery.of(context).size.width * 0.9),
          values: [widget.total, widget.unRegistered, widget.registered],
          labels: ['Registered', 'Unregistered', 'Pending'],
          legendPosition: LegendPosition.Bottom,
        ),
      ),
    );
  }
}
