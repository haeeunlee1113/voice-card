import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:voicequiz/Quiz/quiz_animation.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

enum TtsState { playing, stopped, paused, continued }

class StudyView extends StatefulWidget {
  final String title;
  final List<TestList> list;
  StudyView({Key key, this.title, this.list}) : super(key: key);

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> with WidgetsBindingObserver {
  List<TestList> inputList = List<TestList>();

  int current = 0;
  int listSize;
  int _odd = 0;

  bool _isReading = true;
  bool _next = false;
  bool _initComplete = false;

  FlutterTts flutterTts;
  dynamic languages;
  String language;
  double volume = 1.0;
  double pitch = 1.0;
  double rate = 0.5;

  String _newQuestionText;
  String _newAnswerText;
  String _newText = "";

  TtsState ttsState = TtsState.stopped;

  @override
  void initState() {
    super.initState();
    initTts();
    _initList();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    flutterTts.stop();
    //_stopSpeaking();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) {
      if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive) {
        setState(() {
          _isReading = true;
        });
        _stopSpeaking();
        //flutterTts.stop();
      }

      print(state);
      print("뒤로 가기햇당");
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (inputList.length != widget.list.length) {
        setState(() {});
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(112, 112, 112, 1.0),
          ),
          onPressed: () => {
            _isReading = true,
            _stopSpeaking(),
            //flutterTts.stop(),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TodoListView()),
            )
          },
        ),
        title: Text(
          widget.title,
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
          Image(
            image: AssetImage("assets/images/background@3x.png"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          SwipeDetector(
            swipeConfiguration:
                SwipeConfiguration(horizontalSwipeMinVelocity: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  _progressBar(current),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.72,
                    //padding: EdgeInsets.only(
                    //  top: 20.0, left: 10.0, right: 10.0, bottom: 20.0),
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
                    child: _createStudyCard(),
                  ),
                ],
              ),
            ),
            onSwipeLeft: () {
              setState(() {
                _stopSpeaking();
                if (current < listSize - 1) {
                  current++;
                  //_newText = inputList[current].question;
                  _newQuestionText = inputList[current].question;
                  _newAnswerText = "";
                  if (!_isReading) _speak(_newQuestionText);
                }
              });
            },
            onSwipeRight: () {
              setState(() {
                _stopSpeaking();
                if (current > 0) {
                  current--;
                  //_newText = inputList[current].question;
                  _newQuestionText = inputList[current].question;
                  _newAnswerText = "";
                  if (!_isReading) _speak(_newQuestionText);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  _initList() {
    print("start");
    current = 0;
    inputList = widget.list;
    listSize = inputList.length;
    print("OK");
    print("길이: $listSize");

    if (!_initComplete) _initComplete = true;

    //_newText = inputList[current].question;
    _newQuestionText = inputList[current].question;
    _newAnswerText = "";
  }

  _createStudyCard() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 10, bottom: 30, left: 30, right: 30),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: (MediaQuery.of(context).size.height) * 0.07),
            _questionCard(current),
            SizedBox(height: (MediaQuery.of(context).size.height) * 0.07),
            _answerCard(current),
            SizedBox(height: (MediaQuery.of(context).size.height) * 0.01),
            _isReading ? _readingMode() : _listeningMode(),
          ],
        ),
      ),
    );
  }

  _progressBar(int index) {
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
      percent: (current + 1) / (listSize),
      linearStrokeCap: LinearStrokeCap.roundAll,
      clipLinearGradient: true,
      linearGradient: linearColor,
    );
  }

  _questionCard(int index) {
    final String _text = inputList[index].question;
    return Container(
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
    );
  }

  _answerCard(int index) {
    String _text = inputList[index].answer;
    return Container(
      height: MediaQuery.of(context).size.height * 0.077,
      width: MediaQuery.of(context).size.width * 0.65,
      padding: EdgeInsets.symmetric(
          vertical: (MediaQuery.of(context).size.height) * 0.02,
          horizontal: (MediaQuery.of(context).size.width) * 0.65 * 0.05),
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage("assets/images/studyview_rectangle@3x.png"),
            fit: BoxFit.fill),
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

  _readingMode() {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.1,
        height: MediaQuery.of(context).size.width * 0.1,
        child: Icon(FeatherIcons.volume, color: iconColor, size: 40.0),
      ),
      onTap: () {
        setState(() {
          _isReading = false;
          _newQuestionText = inputList[current].question;
          _speak(_newQuestionText);
        });
      },
    );
    /*return IconButton(
      icon: Icon(FeatherIcons.volume,
          color: iconColor, size: MediaQuery.of(context).size.width * 0.1),
      color: Colors.grey[700],
      iconSize: 30,
      onPressed: () {
        setState(() {
          _isReading = false;
          _speak(_newQuestionText);
        });
      },
    );*/
  }

  _listeningMode() {
    return GestureDetector(
      child: SimpleSpeakerAnimation(),
      onTap: () {
        _stopSpeaking();
        _isReading = true;
      },
    );
    /*return IconButton(
      icon: Icon(Icons.volume_up),
      color: Colors.grey[700],
      iconSize: 30,
      onPressed: () {
        setState(() {
          _stopSpeaking();
          _isReading = true;
        });
      },
    );*/
  }

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
        print("Complete");
        ttsState = TtsState.stopped;
      });
      if (_newQuestionText == "") {
        //답을 말한 경우
        if (!_isReading && current < listSize - 1) {
          //print("증가");
          _newQuestionText = inputList[current + 1].question;
          _newAnswerText = "";
          _speak(_newQuestionText);
          current++;
        } else if (!_isReading && current == listSize - 1) {
          setState(() {
            _isReading = true;
          });
        }
      } else if (_newAnswerText == "") {
        //문제를 말한 경우
        _newQuestionText = "";
        _newAnswerText = inputList[current].answer;
        _speak(_newAnswerText);
      }
      /*
      _odd++;
      if (!_isReading && (_odd % 2 == 0)) {
        //_next = false;
        if (current < listSize - 1) {
          //print("증가");

          current++;
          _newQuestionText = inputList[current].question;
          _newAnswerText = inputList[current].answer;
          _speak();
        }
      }*/
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (Platform.isIOS) {
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

  Future _speak(String _text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (!_isReading) {
      if (_text != null && _text.isNotEmpty) {
        var result = await flutterTts.speak(_text);
        //result = await flutterTts.speak("                       ");
        //result = await flutterTts.speak(_newAnswerText);
        if (result == 1)
          setState(() {
            ttsState = TtsState.playing;
            _next = true;
          });
      }
    }

    /*if (_newQuestionText != null && _newAnswerText != null) {
      if (_newQuestionText.isNotEmpty && _newAnswerText.isNotEmpty) {
        var result = await flutterTts.speak(_newQuestionText);
        //result = await flutterTts.speak("                       ");
        //result = await flutterTts.speak(_newAnswerText);
        if (result == 1)
          setState(() {
            ttsState = TtsState.playing;
            _next = true;
          });
      }
    }*/
  }

  Future _stopSpeaking() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }
}
