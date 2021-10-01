import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:sqflite/sqflite.dart';

import 'flashcard.dart';
import 'flashcard_view.dart';
import 'sql_helper.dart';
import 'quizpage.dart';

class FlashCardPage extends StatefulWidget {
  const FlashCardPage({Key? key}) : super(key: key);

  @override
  _FlashCardPageState createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
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

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  //TextEditingController _titleController = new TextEditingController();
  //TextEditingController _descriptionController = new TextEditingController();

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    int? count = _journals.length;
    int currentNumber = _currentIndex + 1;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$currentNumber / $count'),
              SizedBox(
                width: 250,
                height: 250,
                child: FlipCard(
                  front: FlashcardView(
                    text: _journals[_currentIndex]['question'],
                  ),
                  back: FlashcardView(
                    text: _journals[_currentIndex]['answer'],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton.icon(
                      onPressed: showPreviousCard,
                      icon: Icon(Icons.chevron_left),
                      label: Text('Prev')),
                  OutlinedButton.icon(
                      onPressed: showNextCard,
                      icon: Icon(Icons.chevron_right),
                      label: Text('Next')),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: new FloatingActionButton(
          heroTag: 'Next Page Button',
          child: Icon(Icons.check),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QuizPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  void showNextCard() {
    setState(() {
      _currentIndex =
          (_currentIndex + 1 < _journals.length) ? _currentIndex + 1 : 0;
    });
  }

  void showPreviousCard() {
    setState(() {
      _currentIndex =
          (_currentIndex - 1 >= 0) ? _currentIndex - 1 : _journals.length - 1;
    });
  }
}
