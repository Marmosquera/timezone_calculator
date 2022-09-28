import 'package:flutter/material.dart';
import 'dart:core';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TimeZone Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'TimeZone Calculator'),
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
  late List<TimeZoneData> times;
  TimeZoneData? current;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    times = List.generate(24, (index) => TimeZoneData(index));

    int now = DateTime.now().hour;
    current = times.firstWhere((element) => element.time == now);

    _prefs.then((SharedPreferences prefs) async {
      double w = prefs.getDouble('width') ?? 460;
      double h = prefs.getDouble('height') ?? 780;
      await DesktopWindow.setWindowSize(Size(w, h));
    });

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      final Size size = await DesktopWindow.getWindowSize();
      final SharedPreferences prefs = await _prefs;

      prefs.setDouble('width', size.width);
      prefs.setDouble('height', size.height);

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: <Widget>[buildDataTable(context)])),
    );
  }

  onTap(TimeZoneData timeZoneData) {
    setState(() {
      if (current?.time == timeZoneData.time) {
        current = null;
      } else {
        current = timeZoneData;
      }
    });
  }

  Widget buildDataTable(BuildContext context) {
    return DataTable(
        border: TableBorder.all(width: 1.0, color: Colors.black),
        dataRowHeight: 28.0,
        showCheckboxColumn: false,
        columns: const <DataColumn>[
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('BsAs')),
          DataColumn(label: Text('GMT')),
          DataColumn(label: Text('Porto')),
          DataColumn(label: Text('Rome')),
        ],
        rows: times
            .map(
              (timeZoneData) => DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08);
                    }
                    if (timeZoneData.time.isEven) {
                      return Colors.grey.withOpacity(0.3);
                    }
                    return null;
                  }),
                  cells: <DataCell>[
                    DataCell(Text(
                        (timeZoneData.time - (current?.time ?? 0)).toString())),
                    DataCell(Text(timeZoneData.toBsAs())),
                    DataCell(Text(timeZoneData.toGMT())),
                    DataCell(Text(timeZoneData.toPorto())),
                    DataCell(Text(timeZoneData.toRome())),
                  ],
                  selected: current?.time == timeZoneData.time,
                  onSelectChanged: (b) => onTap(timeZoneData)),
            )
            .toList());
  }
}

class TimeZoneData {
  int time;

  TimeZoneData(this.time);

  String toBsAs() => (time).toString().padLeft(2, '0') + ':00';
  String toGMT() => plus(3).toString().padLeft(2, '0') + ':00';
  String toPorto() => plus(4).toString().padLeft(2, '0') + ':00';
  String toRome() => plus(5).toString().padLeft(2, '0') + ':00';

  int plus(int diff) {
    int val = time + diff;
    if (val > 23) {
      val -= 24;
    }
    return val;
  }
}
