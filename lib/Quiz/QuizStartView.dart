import 'dart:collection';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:voicequiz/Quiz/StudyView.dart';
import 'package:voicequiz/Quiz/QuizView.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/top/ShowTopList.dart';

import 'dart:async';

const initTime = 3;

//quiz

///

class QuizStartView extends StatefulWidget {
  final CardTitle title;
  final List<TestList> dbList;
  QuizStartView({Key key, this.title, this.dbList}) : super(key: key);

  @override
  _QuizStartViewState createState() => _QuizStartViewState();
}

class _QuizStartViewState extends State<QuizStartView> {
  Timer _timer;
  int _time = initTime;
  bool _startQuiz = false;

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title.title,
          style: TextStyle(
              color: Colors.black,
              fontFamily: 'NotoSans',
              fontSize: 27.0,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: new IconButton(
          icon: new Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(112, 112, 112, 1.0),
          ),
          onPressed: () => {
            if (NavigatorState().canPop())
              {Navigator.of(context).pop()}
            else
              {
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                  builder: (context) {
                    return TodoListView();
                  },
                ), (route) => false)
              }
          },
        ),
      ),
      body: Center(child: countDownView()),
    );
  }

  countDownView() {
    return Stack(alignment: Alignment.center, children: <Widget>[
      Image(
        image: AssetImage("assets/images/background@3x.png"),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
      Column(
        //mainAxisSize: MainAxisSize.max,
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.23),
          _quizCountDown(),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          _startStudy(),
        ],
      ),
    ]);
  }

  _quizCountDown() {
    _startTimer();

    return Container(
      //padding: EdgeInsets.all(40.0),
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.width * 0.25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[400],
            offset: Offset(1.0, 3.0),
            blurRadius: 10.0,
            spreadRadius: 0.2,
          ),
        ],
      ),
      child: Text(
        '$_time',
        style: TextStyle(
          fontSize: 50.0,
          fontWeight: FontWeight.w400,
        ),
        //textAlign: TextAlign.center,
      ),
    );
  }

  _startStudy() {
    return GestureDetector(
      onTap: () {
        print('클릭!!');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return StudyView(
              title: widget.title.title,
              list: widget.dbList,
            );
          },
        ), (route) => false);

        //_timer.cancel();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.077,
        width: MediaQuery.of(context).size.width * 0.55,
        padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.07 * 0.3,
          //horizontal: MediaQuery.of(context).size.width * 0.6 * 0.05,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/Rectangle42@3x.png"),
              fit: BoxFit.fill),
        ),
        child: Text(
          '공부하기',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _startTimer() {
    //_time = initTime;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_time > 0) {
          _time--;
        } else {
          _timer.cancel();
          _startQuiz = true;
          startQuiz();
        }
      });
    });
  }

  /////
  ///
  startQuiz() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return QuizView(
          title: widget.title,
          list: widget.dbList,
        );
      },
    ), (route) => false);
  }
}
