import 'package:alfocom_check_speed/services/database_helpers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:date_time_format/date_time_format.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.storage, this.appPath}) : super(key: key);
  final FirebaseStorage storage;
  final String appPath;

  @override
  _HomePageState createState() =>
      _HomePageState(storage: this.storage, appPath: this.appPath);
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirebaseStorage storage;
  final String appPath;
  _HomePageState({this.storage, this.appPath});

  AnimationController _controller;
  Animation<double> _animation;

  var getHistory;
  var isHistoryAvailable;
  final backgroundImage = AssetImage('assets/images/home_background.jpg');

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    // Load the history of speed test results here.
    getHistory = _read();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.cyan[900]]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.yellow[100],
          flexibleSpace: SafeArea(
            child: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    'Check Speed',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'History',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                )
              ],
              onTap: (int index) {
                // Get the tab index tapped
                // Here setState is called to make the floating action button visible
                // only if index of DefaultTabController is 1(History Screen)
                setState(() {});
                print('Index: $index');
                if (index == 1) {}
              },
            ),
          ),
        ),
        body: TabBarView(
          children: [
            Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: SizeTransition(
                        sizeFactor: _animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: RaisedButton(
                            color: Colors.yellow[100],
                            elevation: 5.0,
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45.0),
                              side: BorderSide(color: Colors.teal),
                            ),
                            onPressed: () async {
                              // Here we need to update the history list after a successfull speed test
                              // So, we need to call the "then" function of the "pushNamed" future
                              // to reload the state and update the history list view after returning from the
                              // second screen (speedtest.dart)
                              await Navigator.pushNamed(context, '/speedtest')
                                  .then((value) {
                                setState(() {
                                  getHistory = _read();
                                });
                              });
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: FutureBuilder<List>(
                future: _read(),
                initialData: [],
                builder: (context, snapshot) {
                  return snapshot.hasData
                      ? ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (_, int position) {
                            final item = snapshot.data[position];
                            final datetime = DateTime.parse(item.dateTime);

                            return Card(
                              color: Colors.green[100],
                              child: ListTile(
                                title: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Download Speed :'),
                                        Text(
                                            '${item.downloadSpeed.toStringAsFixed(2)} Mbps')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Upload Speed :'),
                                        Text(
                                            '${item.uploadSpeed.toStringAsFixed(2)} Mbps')
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Ping :'),
                                        Text('${item.pingInMilliseconds} ms')
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date : ${datetime.format('D, M j Y')}',
                                    ),
                                    Text(
                                      'Time : ${datetime.format('h:i:s A')}',
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await _deleteHistory(context, item);

                                    setState(() {});
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: CircularProgressIndicator(),
                        );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Visibility(
          visible: DefaultTabController.of(context).index == 1 ? true : false,
          child: FloatingActionButton.extended(
            onPressed: () async {
              isHistoryAvailable = await availableSpeedTestResults();
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  if (isHistoryAvailable != false) {
                    return AlertDialog(
                      backgroundColor: Colors.amber[100],
                      title: Text(
                        'Deleting all history.',
                      ),
                      content: Text(
                        'Are you sure?',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(20, 20),
                        ),
                      ),
                      actions: [
                        RaisedButton(
                          color: Colors.yellow[100],
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45.0),
                            side: BorderSide(color: Colors.teal),
                          ),
                          onPressed: () async {
                            await _deleteRecords();
                            Navigator.pop(context);
                            setState(() {});
                          },
                          child: Text(
                            'Yes',
                          ),
                        ),
                        RaisedButton(
                          color: Colors.yellow[100],
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45.0),
                            side: BorderSide(color: Colors.teal),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'No',
                          ),
                        ),
                      ],
                      elevation: 24.0,
                    );
                  } else {
                    return AlertDialog(
                      content: Text(
                        'Nothing to delete here.',
                      ),
                      backgroundColor: Colors.amber[100],
                      title: Text(
                        'No history available.',
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(20, 20),
                        ),
                      ),
                      actions: [
                        RaisedButton(
                          color: Colors.yellow[100],
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(45.0),
                            side: BorderSide(color: Colors.teal),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Ok',
                          ),
                        ),
                      ],
                    );
                  }
                },
              );
            },
            label: Text('Delete all.'),
            icon: Icon(Icons.delete_forever),
            backgroundColor: Colors.teal[600],
          ),
        ),
      ),
    );
  }

  // Future to load all the speed test history results
  Future<List<SpeedHistory>> _read() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    var speedHistory;
    speedHistory = await helper.querySpeedHistories();
    //setState(() {});

    if (speedHistory == null) {
      print('No rows were returned.');
    }
    return speedHistory;
  }

  // Future to delete all history records.
  Future _deleteRecords() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    var deleteRecords = await helper.deleteFromSpeedHistoryTable();
    print('deleteRecrods : $deleteRecords');
  }

  // Future to delete a particular history record.
  Future _deleteHistory(BuildContext context, item) async {
    DatabaseHelper helper = DatabaseHelper.instance;
    await helper.deleteSelectedFromSpeedHistoryTable(item.id);
    print('Item ${item.id} deleted.');
  }

  Future<bool> availableSpeedTestResults() async {
    var numberOfRecords = await _read().then((value) => value.length);
    print('numberOfRecords = $numberOfRecords');
    if (numberOfRecords != 0) {
      return true;
    } else {
      return false;
    }
  }
}
