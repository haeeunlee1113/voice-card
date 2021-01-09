import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/Quiz/QuizStartView.dart';
import 'ShowTopList.dart';

List<String> topImage = [
  'assets/images/tutorial1_1.png',
  'assets/images/tutorial1_2.png',
  'assets/images/tutorial1_3.png',
  'assets/images/tutorial1_4.png',
  'assets/images/tutorial1_5.png',
  'assets/images/tutorial1_6.png',
  'assets/images/tutorial1_7.png',
];

List<String> quizImage = [
  'assets/images/tutorial2_1.png',
  'assets/images/tutorial2_2.png',
  'assets/images/tutorial2_3.png',
  'assets/images/tutorial2_4.png',
];

class TutorialView extends StatefulWidget {
  int pageNum;
  final CardTitle title;
  final List<TestList> list;
  TutorialView({Key key, this.pageNum, this.title, this.list})
      : super(key: key);
  @override
  _TutorialViewState createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.pageNum == 1) {
      return _topviewTutorial();
    } else if (widget.pageNum == 2) {
      return _quizviewTutorial();
    }
  }

  _topviewTutorial() {
    return Scaffold(
      body: Stack(
        children: [
          Image(
            image: AssetImage("assets/images/background@3x.png"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  //color: Colors.lightBlue,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Swiper(
                    /*control: SwiperControl(
                      color: Color.fromRGBO(56, 135, 195, 1.0),
                    ),*/
                    pagination: SwiperPagination(
                        //alignment: Alignment.bottomCenter,
                        //margin: EdgeInsets.all(10),
                        builder: new DotSwiperPaginationBuilder(
                      color: Colors.grey[300],
                      activeColor: Color.fromRGBO(56, 135, 195, 1.0),
                    )),
                    scale: 0.8,
                    viewportFraction: 0.8,
                    loop: false,
                    itemCount: topImage.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        topImage[index],
                        //fit: BoxFit.fill,
                      );
                    },
                  )),
              _startIcon(),
            ],
          ),
        ],
      ),
      /*Stack(
        children: [
          Image(
            image: AssetImage("assets/images/background@3x.png"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  //color: Colors.lightBlue,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: SwipeDetector(
                    swipeConfiguration:
                        SwipeConfiguration(horizontalSwipeMinVelocity: 100),
                    child: Image.asset(
                      topImage[index],
                    ),
                    onSwipeLeft: () {
                      setState(() {
                        if (index < topImage.length - 1) index++;
                      });
                    },
                    onSwipeRight: () {
                      setState(() {
                        if (index > 0) index--;
                      });
                    },
                  ),
                ),
                _startIcon(),
              ],
            ),
          ),
        ],
      ),*/
    );
  }

  _quizviewTutorial() {
    return Scaffold(
      body: Stack(
        children: [
          Image(
            image: AssetImage("assets/images/background@3x.png"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  //color: Colors.lightBlue,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Swiper(
                    /*control: SwiperControl(
                      color: Color.fromRGBO(56, 135, 195, 1.0),
                    ),*/
                    pagination: SwiperPagination(
                        //alignment: Alignment.bottomCenter,
                        //margin: EdgeInsets.all(10),
                        builder: new DotSwiperPaginationBuilder(
                      color: Colors.grey[300],
                      activeColor: Color.fromRGBO(56, 135, 195, 1.0),
                    )),
                    scale: 0.8,
                    viewportFraction: 0.8,
                    loop: false,
                    itemCount: quizImage.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        quizImage[index],
                        //fit: BoxFit.fill,
                      );
                    },
                  )),
              _quizStartIcon(),
            ],
          ),
        ],
      ),

      /*Stack(
        children: [
          Image(
            image: AssetImage("assets/images/background@3x.png"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  //color: Colors.lightBlue,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: SwipeDetector(
                    swipeConfiguration:
                        SwipeConfiguration(horizontalSwipeMinVelocity: 100),
                    child: Image.asset(
                      quizImage[index],
                    ),
                    onSwipeLeft: () {
                      setState(() {
                        if (index < quizImage.length - 1) index++;
                      });
                    },
                    onSwipeRight: () {
                      setState(() {
                        if (index > 0) index--;
                      });
                    },
                  ),
                ),
                _startIcon(),
              ],
            ),
          ),
        ],
      ),*/
    );
  }

  _quizStartIcon() {
    return GestureDetector(
      onTap: () {
        LoginDBHelper().updateStudy();

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return QuizStartView(title: widget.title, dbList: widget.list);
          },
        ), (route) => false);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
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
          '시작하기',
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

  _startIcon() {
    return GestureDetector(
      onTap: () {
        LoginDBHelper().updateTop();
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return TodoListView();
          },
        ), (route) => false);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.07,
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
          '시작하기',
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
}
