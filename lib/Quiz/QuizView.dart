import 'dart:math';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:collection';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:voicequiz/Quiz/STT.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:voicequiz/Quiz/patterns.dart';
import 'package:voicequiz/Quiz/quiz_animation.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:flutter/cupertino.dart';
import 'package:need_resume/need_resume.dart';

const int incorrect_num = 3; // 문제를 3번 틀리면 안나옴
const int min_queue = 5; // 최근 5개는 안나온다

class Quiz {
  String question;
  String answer;
  int failCount;

  Quiz({this.question, this.answer, this.failCount});
}

enum TtsState { playing, stopped, paused, continued }

List<TestList> inputList = [];
List<Quiz> quizList = [];
Queue<Quiz> que;
int quiz_num; // 초기 문제 개수
int correct_num; //맞은 문제 개수
int list_len; // 현재 list의 길이
int current; // 현재 문제의 index

int progress;
int total_progress;
//int item_count; // page view 개수
bool correct;
bool show_answer;
bool end_quiz;
InterstitialAd ad = getAd();

class QuizView extends StatefulWidget {
  final CardTitle title;
  final List<TestList> list;
  //final List<Quiz> dbList;
  QuizView({Key key, this.title, this.list}) : super(key: key);

  @override
  _QuizViewState createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> with WidgetsBindingObserver {
  //tts
  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;
  bool isSpeckEnd = false;
  bool skip = false;

  String _newVoiceText;

  TtsState ttsState = TtsState.stopped;

  //stt
  SpeechRecognition _speech;
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;
  Language selectedLang = stt_languages.first;
  Duration listen_time = new Duration(seconds: 3);
  String transcription = '';

  //timer
  Timer _timer; //타이머
  var _time = 0;
  var _isTimerRunning = false;

  //audio
  AudioCache player = new AudioCache(); //오디오 플레이어

  @override
  void initState() {
    super.initState();
    if (mounted) {
      initQuizList(); //initialization
      initTts();
      _newVoiceText = quizList[current].question; //inputList[current].question;
      activateSpeechRecognizer();
      isSpeckEnd = false;
      progress = 0;
    }
    WidgetsBinding.instance.addObserver(this);
    ad..load();
  }

  //또 setState dispose 어쩌고 뜨면 위에 주석 해제 & dispose 할거 다해주기
  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
    _speech.stop();
    _timer?.cancel();
    _time = 0;
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopSpeaking();
      _stopListening();
      _resetTimer();
      //flutterTts.stop();
    }

    print("바뀜");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(112, 112, 112, 1.0),
          ),
          tooltip: 'Hi!',
          onPressed: () => {
            if (end_quiz)
              {
                ad.show(
                    anchorType: AnchorType.top,
                    anchorOffset: 0.0,
                    horizontalCenterOffset: 0.0),
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return TodoListView();
                  },
                ), (route) => false)
              }
            else
              {
                _showEndAlertDialog(context),
              }
          },
        ),
        title: Text(
          widget.title.title,
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'NotoSans',
              fontSize: 27.0,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color.fromARGB(255, 240, 243, 246),
          ),
          Swiper(
            scrollDirection: axisDirectionToAxis(AxisDirection.right),
            onIndexChanged: (value) {
              _setNextQuiz();
            },
            itemCount: 1,
            itemBuilder: (context, index) {
              return Text(quizList[current].question);
            },
          ),
          /*SwipeDetector(
            swipeConfiguration:
                SwipeConfiguration(horizontalSwipeMinVelocity: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  _progressBar(),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[400],
                          offset: Offset(0.0, -3.0),
                          blurRadius: 10.0,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: end_quiz
                        ? _endWidget()
                        : _createQuizView(quizList[current].question),
                  ),
                ],
              ),
            ),
            onSwipeLeft: () {
              setState(() {
                if (ttsState == TtsState.playing && !end_quiz) {
                  skip = true;
                  _timer?.cancel();
                  _time = 0;
                  //_resetTimer();
                  print("1: $skip");
                  _stopSpeaking();
                  print("3: $skip");
                  _stopListening();
                  print("4");
                  _setNextQuiz();
                  print("5");
                  if (!end_quiz) _speak();
                }
              });
            },
          ),*/
        ],
      ),
    );
  }

  initQuizList() {
    inputList = widget.list;
    quiz_num = inputList.length; //widget.dbList.length;
    list_len = quiz_num;
    correct_num = 0;
    total_progress = 3 * quiz_num;
    skip = false;

    quizList = [];

    //item_count = quiz_num;
    Random rnd = new Random();
    current = rnd.nextInt(list_len);
    correct = false;
    show_answer = false;
    end_quiz = false;
    que = new Queue();

    if (quizList.length == 0) {
      for (int i = 0; i < list_len; i++) {
        Quiz tmp = Quiz(
            question: inputList[i].question, //widget.dbList[i].question,
            answer: inputList[i].answer, //widget.dbList[i].answer,
            failCount: 0);
        quizList.add(tmp);
      }
    }
  }

  _createQuizView(String _questionText) {
    //얘는 계속 돌아가네....
    //_speak();
    if (!isSpeckEnd && !end_quiz) {
      setState(() => isSpeckEnd = true);
      _speak();
    }
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 30, left: 30, right: 30),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: (MediaQuery.of(context).size.height) * 0.07),
            _questionWidzet(_questionText),
            SizedBox(height: (MediaQuery.of(context).size.height) * 0.07),
            if (show_answer)
              _answerWidget()
            else if (_isListening)
              MicAnimation()
            else if (ttsState == TtsState.playing)
              SpeakerAnimation()
          ],
        ),
      ),
    );
  }

  _progressBar() {
    const linearColor = LinearGradient(colors: [
      Color.fromRGBO(144, 179, 213, 1.0),
      Color.fromRGBO(78, 134, 190, 1.0)
    ], begin: Alignment.centerLeft, end: Alignment.centerRight);

    return LinearPercentIndicator(
      width: MediaQuery.of(context).size.width * 0.65,
      alignment: MainAxisAlignment.center,
      animation: true,
      animateFromLastPercent: true,
      lineHeight: 20.0,
      animationDuration: 500,
      percent: progress / total_progress,
      linearStrokeCap: LinearStrokeCap.roundAll,
      clipLinearGradient: true,
      linearGradient: linearColor,
    );
  }

  _questionWidzet(String _text) {
    return Column(
      children: <Widget>[
        Container(
          height: (MediaQuery.of(context).size.height) * 0.32,
          width: MediaQuery.of(context).size.width * 0.65,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Text(
              '$_text',
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  _answerWidget() {
    String _text = quizList[current].answer;

    return Container(
      height: MediaQuery.of(context).size.height * 0.077,
      width: MediaQuery.of(context).size.width * 0.65,
      padding: EdgeInsets.symmetric(
          vertical: (MediaQuery.of(context).size.height) * 0.015,
          horizontal: (MediaQuery.of(context).size.width) * 0.65 * 0.05),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/Path38@3x.png"), fit: BoxFit.fill),
      ),
      child: SingleChildScrollView(
        child: Text(
          '$_text',
          style: TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  _setNextQuiz() {
    Quiz tmp;

    tmp = quizList.removeAt(current);
    if (!correct) {
      tmp.failCount++;
      progress++;
      if (tmp.failCount < incorrect_num) que.add(tmp);
    } else {
      progress += 3 - tmp.failCount;
    }

    list_len = quizList.length;
    if (que.isEmpty && list_len == 0) {
      setState(() {
        end_quiz = true;
      });
    } else if (list_len == 0 || que.length > min_queue) {
      tmp = que.removeFirst();
      quizList.add(tmp);
    }

    if (!end_quiz) {
      Random rnd = new Random();
      current = rnd.nextInt(quizList.length);
      correct = false;
      transcription = "";
      show_answer = false;

      final String _questionText = quizList[current].question;
      _onChange(_questionText);
    }
  }

  _endWidget() {
    flutterTts.stop();
    _resetTimer();
    //_timer?.cancel();
    int percent = ((correct_num / quiz_num) * 100).toInt();
    savePercent(widget.title, percent);
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
          ),
          Text(
            widget.title.title,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 70,
              color: Color.fromRGBO(16, 50, 77, 1.0),
              fontWeight: FontWeight.w400,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '암기했습니다.',
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          GestureDetector(
            onTap: () {
              print('클릭!!');

              ad.show(
                  anchorType: AnchorType.top,
                  anchorOffset: 0.0,
                  horizontalCenterOffset: 0.0);

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return TodoListView();
                },
              ), (route) => false);
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.077,
              width: MediaQuery.of(context).size.width * 0.55,
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.07 * 0.3,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/Rectangle42@3x.png"),
                    fit: BoxFit.fill),
              ),
              child: Text(
                '홈으로',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  savePercent(CardTitle cardTitle, int percent) async {
    TitleBloc titleBloc = TitleBloc();
    await titleBloc.updatePercent(cardTitle.pk, percent);
    if (cardTitle.id != 0) await titleBloc.updateFolderPercents(cardTitle.id);
  }

  /////tts
  initTts() {
    flutterTts = FlutterTts();

    //_getLanguages();
    //languages = "ko_KR";
    flutterTts.setLanguage("ko-KR");

    if (Platform.isAndroid) {
      _getEngines();
      rate = 1.0;
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete,,,,,2: $skip");
        ttsState = TtsState.stopped;
        if (Platform.isIOS && !end_quiz) {
          if (!skip) {
            _playAudio("notification_alert.mp3");
            Timer(Duration(seconds: 1), () {
              _startTimer();
              _listen();
            });
          } else
            skip = false;
        }
        if (Platform.isAndroid && !end_quiz) {
          _playAudio("notification_alert.mp3");
          Timer(Duration(seconds: 1), () {
            _startTimer();
            _listen();
          });
        }
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (Platform.isIOS) {
      //volume = 1.0;
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  Future _getLanguages() async {
    languages = await flutterTts.getLanguages;
    if (languages != null) setState(() => languages);
  }

  Future _getEngines() async {
    var engines = await flutterTts.getEngines;
    if (engines != null) {
      for (dynamic engine in engines) {
        print(engine);
      }
    }
  }

  Future _speak() async {
    //await flutterTts.setVolume(volume);
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null && !end_quiz) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1)
          setState(() {
            ttsState = TtsState.playing;
          });
      }
    }
  }

  Future _stopSpeaking() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _time++;
        print(_time);
      });
      if (_time > 3) _isAnswer();
    });
  }

  void _resetTimer() {
    setState(() {
      _isTimerRunning = false;
      _timer?.cancel();
      _time = 0;
    });
  }

  void _listen() {
    //if (Platform.isAndroid) setState(() => _isListening = true);
    setState(() => _isListening = true);
    _speech.listen(locale: selectedLang.code).then((result) {
      print('_MyAppState.start => result ${result}');
    }); /*.timeout(listen_time);*/
  }

  //.timeout(listen_time, onTimeout: () => _speech.stop());

  void _stopListening() => _speech.stop().then((result) {
        if (Platform.isIOS) {
          setState(() => _isListening = result /*false*/ /*result*/);
        }
        if (Platform.isAndroid) {
          setState(() => _isListening = false);
        }
      });

  void _cancelListening() => _speech.cancel().then((result) {
        if (Platform.isIOS) {
          setState(() => _isListening = result /*false*/ /*result*/);
        }
        if (Platform.isAndroid) {
          setState(() => _isListening = false);
        }
      });

  void activateSpeechRecognizer() {
    print('_MyAppState.activateSpeechRecognizer... ');
    _speech = new SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setCurrentLocaleHandler(onCurrentLocale);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);

    _speech
        .activate()
        .then((res) => setState(() => _speechRecognitionAvailable = res));
  }

  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  void onRecognitionStarted() => setState(() => _isListening = true);

  void onRecognitionResult(String text) => setState(() => transcription = text);

  void onRecognitionComplete() => setState(() {
        _isListening = false;
        //_isAnswer();
      });

  _isAnswer() {
    setState(() {
      _stopListening();
      _resetTimer();
      int distance;
      if (transcription == "")
        distance = answerDistance;
      else
        distance = getDistance(transcription, quizList[current].answer);

      if (distance < answerDistance) {
        print("정답");
        _playAudio("correct_answer.mp3");
        correct = true;
        correct_num++;
      } else {
        print("땡");
        _playAudio("wrong_answer.mp3");
      }
      show_answer = true;
      Timer(Duration(seconds: 2), () {
        _setNextQuiz();
        _speak();
      });
    });
  }

  _playAudio(String file) async {
    await player.play(file, volume: 1.0);
  }

  _showEndAlertDialog(BuildContext context) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("퀴즈를 종료하시겠습니까?",
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            actions: <Widget>[
              FlatButton(
                child: Text("취소",
                    style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context);
                  //_isAnswer();
                },
              ),
              FlatButton(
                child: Text("확인",
                    style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                onPressed: () {
                  //Navigator.pop(context);
                  setState(() {
                    end_quiz = true;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
