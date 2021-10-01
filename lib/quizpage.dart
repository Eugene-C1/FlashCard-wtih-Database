import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:new_sqlite/flashcardpage.dart';
import 'package:quiver/async.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flashcard_view.dart';
import 'resultpage.dart';
import 'sql_helper.dart';
import 'sharedpreferences.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
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

  String controller = '';
  bool check = false;
  int score = 0;
  int _currentIndex = 0;
  int points = 0;

  @override
  void initState() {
    super.initState();
    _refreshJournals();

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds:
                levelClock) // gameData.levelClock is a user entered number elsewhere in the applciation
        );

    _controller.forward();

    _controller.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResultPage(),
            ),
          );
        }
      },
    ); // Loading the diary when the app starts
  }

  late AnimationController _controller;
  int levelClock = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextEditingController _answerController = new TextEditingController();
  TextEditingController _oldAnswerController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    int? count = _journals.length;
    int currentNumber = _currentIndex + 1;
    return Material(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('$currentNumber / $count'),
                    Countdown(
                      animation: StepTween(
                        begin: levelClock, // THIS IS A USER ENTERED NUMBER
                        end: 0,
                      ).animate(_controller),
                    ),
                  ],
                ),
                SizedBox(
                  width: 250,
                  height: 250,
                  child: FlipCard(
                    front: FlashcardView(
                      text: _journals[_currentIndex]['question'],
                    ),
                    back: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset:
                                Offset(0.0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            child: TextField(
                              controller: _answerController,
                              decoration: InputDecoration(
                                hintText: 'Enter Answer',
                                labelStyle: TextStyle(color: Colors.white),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton.icon(
                      onPressed: showPreviousCard,
                      icon: Icon(Icons.chevron_left),
                      label: Text('Prev'),
                    ),
                    OutlinedButton.icon(
                      onPressed: showNextCard,
                      icon: Icon(Icons.chevron_right),
                      label: Text('Next'),
                    ),
                  ],
                ),
                Text('$score'),
                Text('data')
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showNextCard() {
    setState(
      () {
        controller = _answerController.text.toString();
        check = _journals[_currentIndex]['answer'] == controller;

        if (check) {
          score++;
          MySharedPreferences.instance.setIntegerValue('score', score);
          MySharedPreferences.instance.setIntegerValue('counter', score);
          //MySharedPreferences.instance.setIntegerValue('score', score);
        }

        _currentIndex =
            (_currentIndex + 1 < _journals.length) ? _currentIndex + 1 : 0;

        _answerController.clear();
      },
    );
  }

  void showPreviousCard() {
    setState(
      () {
        score--;
        MySharedPreferences.instance.setIntegerValue('score', score);
        MySharedPreferences.instance.setIntegerValue('counter', score);
        //MySharedPreferences.instance.setIntegerValue('score', score);

        _currentIndex =
            (_currentIndex - 1 >= 0) ? _currentIndex - 1 : _journals.length - 1;

        _answerController.text = controller;
      },
    );
  }
}

class Countdown extends AnimatedWidget {
  Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    print('animation.value  ${animation.value} ');
    print('inMinutes ${clockTimer.inMinutes.toString()}');
    print('inSeconds ${clockTimer.inSeconds.toString()}');
    print(
        'inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');

    return Text(
      "$timerText",
      style: TextStyle(
        fontSize: 20,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
