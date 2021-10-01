import 'package:flutter/material.dart';
import 'package:new_sqlite/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sql_helper.dart';
import 'sharedpreferences.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  int score = 0;
  int points = 0;

  @override
  void initState() {
    super.initState();
    _refreshJournals();

    MySharedPreferences.instance
        .getIntegerValue("score")
        .then((value) => setState(() {
              score = value;
            }));

    MySharedPreferences.instance
        .getIntegerValue("points")
        .then((value) => setState(() {
              points = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    int? count = _journals.length;
    return Material(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text('This is result Page'),
            ),
            Center(
              child: Text('You Scored $score / $count'),
            ),
            Center(
              child: Text('You gained a total of $score points'),
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          heroTag: 'Next Page Button',
          child: Icon(Icons.check),
          onPressed: () {
            int count = 0;
            points = points + score;
            MySharedPreferences.instance.setIntegerValue('points', points);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ListPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
