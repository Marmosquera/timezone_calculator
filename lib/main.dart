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

  @override
  void initState() {
    super.initState();
    times = List.generate(24, (index) => TimeZoneData(index));

    int now = DateTime.now().hour;
    current = times.firstWhere((element) => element.time == now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: <Widget>[buildDataTable(context)])));
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
  String toGMT() => (time + 3).toString().padLeft(2, '0');
  String toPorto() => (time + 4).toString().padLeft(2, '0');
  String toRome() => (time + 5).toString().padLeft(2, '0');
}
