import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hoşgeldiniz',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlayerNamePage()),
                );
              },
              child: Text('Başla'),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerNamePage extends StatefulWidget {
  @override
  _PlayerNamePageState createState() => _PlayerNamePageState();
}

class _PlayerNamePageState extends State<PlayerNamePage> {
  final _playerOneController = TextEditingController();
  final _playerTwoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yarışmacı İsimleri'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _playerOneController,
              decoration: InputDecoration(
                labelText: 'Birinci Yarışmacı',
                labelStyle: TextStyle(fontSize: 18),
              ),
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _playerTwoController,
              decoration: InputDecoration(
                labelText: 'İkinci Yarışmacı',
                labelStyle: TextStyle(fontSize: 18),
              ),
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizPage(
                      playerOne: _playerOneController.text,
                      playerTwo: _playerTwoController.text,
                    ),
                  ),
                );
              },
              child: Text('Başla'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playerOneController.dispose();
    _playerTwoController.dispose();
    super.dispose();
  }
}

class QuizPage extends StatefulWidget {
  final String playerOne;
  final String playerTwo;

  QuizPage({required this.playerOne, required this.playerTwo});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool isPlayerOneTurn = true;
  int playerOneScore = 0;
  int playerTwoScore = 0;
  late Timer _timer;
  int _countDown = 15;

  final List<Map<String, Object>> questions = [
    {
      'question': 'Dünyanın ilk bilgisayar programcısı olarak kabul edilen kişi kimdir?',
      'options': ['Alan Turing', 'Ada Lovelace', 'Charles Babbage', 'John von Neumann'],
      'answer': 'Ada Lovelace'
    },
    {
      'question': 'İlk yüksek seviyeli programlama dili hangisidir?',
      'options': ['COBOL', 'FORTRAN', 'BASIC', 'ALGOL'],
      'answer': 'FORTRAN'
    },
    {
      'question': 'İnternetin temellerini atan TCP/IP protokolünü kim geliştirmiştir?',
      'options': ['Tim Berners-Lee', 'Vinton Cerf ve Robert Kahn', 'Linus Torvalds', 'Dennis Ritchie ve Ken Thompson'],
      'answer': 'Vinton Cerf ve Robert Kahn'
    },
    {
      'question': '1980\'lerde kişisel bilgisayar devrimini başlatan işletim sistemi hangisidir?',
      'options': ['Windows', 'Mac OS', 'MS-DOS', 'Unix'],
      'answer': 'MS-DOS'
    },
    {
      'question': 'C programlama dilini kim geliştirmiştir?',
      'options': ['James Gosling', 'Bjarne Stroustrup', 'Dennis Ritchie', 'Guido van Rossum'],
      'answer': 'Dennis Ritchie'
    },
  ];

  int currentQuestionIndex = 0;

  void checkAnswer(String selectedOption) {
    final currentQuestion = questions[currentQuestionIndex];
    final correctAnswer = currentQuestion['answer'] as String;

    bool isCorrect = selectedOption == correctAnswer;
    if (isCorrect) {
      setState(() {
        if (isPlayerOneTurn) {
          playerOneScore += 20;
        } else {
          playerTwoScore += 20;
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Doğru Bildiniz!' : 'Yanlış Bildiniz'),
          content: Text(isCorrect
              ? 'Tebrikler, doğru cevap verdiniz!'
              : 'Maalesef, yanlış cevap verdiniz. Doğru cevap: $correctAnswer'),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                nextQuestion();
              },
            ),
          ],
        );
      },
    );
  }

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        currentQuestionIndex = 0;
        shuffleQuestions();
      }
      isPlayerOneTurn = !isPlayerOneTurn;
      _countDown = 15;
    });
  }

  void shuffleQuestions() {
    setState(() {
      questions.shuffle();
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_countDown == 0) {
          timer.cancel();
          setState(() {
            nextQuestion();
          });
        } else {
          setState(() {
            _countDown--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    super.initState
      ();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];
    final currentPlayer = isPlayerOneTurn ? widget.playerOne : widget.playerTwo;
    final currentPlayerScore = isPlayerOneTurn ? playerOneScore : playerTwoScore;

    if (playerOneScore >= 100 || playerTwoScore >= 100) {
      String winner = playerOneScore >= 100 ? widget.playerOne : widget.playerTwo;
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz App'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tebrikler $winner!',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Kazanan Skor: ${playerOneScore >= 100 ? playerOneScore : playerTwoScore}',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text('Yeniden Başla'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
        centerTitle: true,
      ),
      backgroundColor: isPlayerOneTurn ? Colors.red : Colors.blue,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Süre: $_countDown',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
            Text(
              'Sıra: $currentPlayer',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              'Puan: $currentPlayerScore',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Text(
                  currentQuestion['question'] as String,
                  style: TextStyle(fontSize: 32, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: (currentQuestion['options'] as List<String>).map((option) {
                return ElevatedButton(
                  onPressed: () => checkAnswer(option),
                  child: Text(option, style: TextStyle(fontSize: 20)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
