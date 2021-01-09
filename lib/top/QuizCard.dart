import 'package:flutter/material.dart';
import 'package:voicequiz/top/Style.dart';
import 'package:voicequiz/top/ShakeAnimate.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/CRUD/EditView.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:voicequiz/CRUD/download.dart';
import 'package:intl/intl.dart';
import 'package:voicequiz/CRUD/textDesign.dart';
import 'package:voicequiz/Quiz/QuizStartView.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/svg.dart';
import 'package:adobe_xd/blend_mask.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:voicequiz/top/ShowTutorial.dart';

class NormalQuizView extends StatefulWidget {
  final userName;
  final CardTitle title;
  final bool search;
  final bool searchFolder;
  final bool update;
  final bool longPress;
  const NormalQuizView(
      {Key key,
      this.title,
      this.search,
      this.userName,
      this.searchFolder,
      this.update,
      this.longPress})
      : super(key: key);
  @override
  _NormalQuizViewState createState() => _NormalQuizViewState();
}

class _NormalQuizViewState extends State<NormalQuizView>
    with SingleTickerProviderStateMixin {
  CardTitle quiz;
  int num = 0;
  bool type;
  QTestBloc qTestBloc;
  List<TestList> list = List<TestList>();
  TitleBloc titleBloc = TitleBloc();
  String date;
  int result = -1;
  bool updateFlag = false;
  CardTitle newTitle = CardTitle();
  CardTitle dbTitle = CardTitle(count: 0, percentage: 0);
  UserInfo user;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    qTestBloc = QTestBloc(widget.title.pk);
    if (widget.update) {
      checkServer(widget.title);
    }
    if (widget.title.dbFolder == 1) getCardTitle(widget.title.pk);
    getQuizList(widget.title.pk);
    quiz = widget.title;
    if (!widget.search) {
      if (widget.title.dbFolder == 1)
        type = false;
      else
        type = true;
    } else
      type = !(widget.title.folder);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (list.length == 0 && mounted) setState(() {});
      if (result == -1 && mounted) setState(() {});
    });
    num = list.length;

    return (type) ? QuizWidget() : FolderWidget();
  }

  FolderCard() {
    return Stack(
      children: <Widget>[
        Container(
          height: 115.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(
            vertical: 7.0,
          ),
          child: _folder(),
        ),
      ],
    );
  }

  _folder() {
    return SizedBox(
      width: 343.0,
      height: 98.0,
      child: Stack(
        children: <Widget>[
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 0.0, 343.0, 98.4),
            size: Size(343.0, 98.4),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            pinBottom: true,
            child: SvgPicture.string(
              '<svg viewBox="16.0 179.7 343.0 98.4" ><defs><linearGradient id="gradient" x1="0.5" y1="0.069803" x2="0.5" y2="0.266693"><stop offset="0.0" stop-color="#ffbcd5e9"  /><stop offset="1.0" stop-color="#ff89b3d5"  /></linearGradient></defs><path transform="translate(16.0, 179.67)" d="M 6.00029993057251 98.42940521240234 C 2.686500072479248 98.42940521240234 0 95.74290466308594 0 92.42910003662109 L 0 13.14360046386719 L 0 6.00029993057251 C 0 2.686500072479248 2.686500072479248 0 6.00029993057251 0 L 72 0 C 75.31380462646484 0 77.99940490722656 2.686500072479248 77.99940490722656 6.00029993057251 L 77.99940490722656 7.14330005645752 L 336.9996032714844 7.14330005645752 C 340.3134155273438 7.14330005645752 342.9999084472656 9.829800605773926 342.9999084472656 13.14360046386719 L 342.9999084472656 92.42910003662109 C 342.9999084472656 95.74290466308594 340.3134155273438 98.42940521240234 336.9996032714844 98.42940521240234 L 6.00029993057251 98.42940521240234 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 12.1, 343.0, 86.3),
            size: Size(343.0, 98.4),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            pinBottom: true,
            child: SvgPicture.string(
              '<svg viewBox="16.0 191.8 343.0 86.3" ><defs><linearGradient id="gradient" x1="0.351281" y1="0.113246" x2="0.733405" y2="0.911175"><stop offset="0.0" stop-color="#ffbcd5e9"  /><stop offset="1.0" stop-color="#ffcee1f0"  /></linearGradient></defs><path transform="translate(906.0, 166.81)" d="M -553.00048828125 111.2850036621094 L -806.6016235351562 111.2850036621094 L -883.9998168945312 111.2850036621094 C -887.3135986328125 111.2850036621094 -890.0001220703125 108.598503112793 -890.0001220703125 105.2856063842773 L -890.0001220703125 37.90530014038086 C -890.0001220703125 34.59149932861328 -887.3135986328125 31.90500068664551 -883.9998168945312 31.90500068664551 L -816.3013305664062 31.90500068664551 L -811.288330078125 27.25362205505371 C -810.1890258789062 25.87994384765625 -808.4981689453125 25.00020027160645 -806.6016235351562 25.00020027160645 L -553.00048828125 25.00020027160645 C -549.6867065429688 25.00020027160645 -547.0001831054688 27.68580055236816 -547.0001831054688 30.99960136413574 L -547.0001831054688 105.2856063842773 C -547.0001831054688 105.4538345336914 -547.0071411132812 105.6204452514648 -547.0206909179688 105.7851791381836 C -547.274658203125 108.8644104003906 -549.8549194335938 111.2850036621094 -552.9996337890625 111.2850036621094 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  QuizCard() {
    return Stack(
      children: <Widget>[
        Container(
          height: 115.0,
          margin: EdgeInsets.symmetric(
            vertical: 7.0,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/Rectangle 76@3x.png'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }

  QuizCardContent() {
    return Container(
        child: Container(
      constraints: BoxConstraints.expand(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Stack(children: [
            Positioned(
                child: (!widget.search)
                    ? Align(
                        alignment: Alignment(-1.0, 0.0),
                        child: Container(
                          padding: EdgeInsets.all(0.0),
                          margin: EdgeInsets.all(0.0),
                          child: IconButton(
                            iconSize: 50,
                            icon: Image.asset('assets/images/Ellipse 3@3x.png'),
                          ),
                        ))
                    : Container()),
            Positioned(
                child: (!widget.search)
                    ? Align(
                        alignment: Alignment(-1.0, 0.1),
                        child: Container(
                          padding: EdgeInsets.only(left: 30.0, bottom: 20.0),
                          margin: EdgeInsets.all(0.0),
                          child: Text(
                            '${quiz.percentage}' '%',
                            style: TextStyle(
                                fontSize: 28, color: Color(0xffa0c7e4)),
                          ),
                        ))
                    : Container())
          ]),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                    width: 25,
                    color: Colors.transparent,
                  ),
                  Text(
                    quiz.title,
                    style: headerTextStyle(),
                  ),
                  Text(" (", style: regularTextStyle()),
                  Text(
                    '${quiz.count}',
                    style: regularTextStyle(),
                  ),
                  Text(") ", style: regularTextStyle()),
                ]),
                Row(
                  children: <Widget>[
                    Container(
                      width: 25,
                      color: Colors.transparent,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(
                          quiz.description,
                          style: subHeaderTextStyle(),
                        )),
                  ],
                )
              ]),
        ],
      ),
    ));
  }

  FolderCardContent() {
    return Container(
        child: Container(
      padding: EdgeInsets.only(top: 15),
      constraints: BoxConstraints.expand(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Stack(children: [
            Positioned(
                child: (!widget.search)
                    ? Align(
                        alignment: Alignment(-1.0, 0.0),
                        child: Container(
                          padding: EdgeInsets.all(0.0),
                          margin: EdgeInsets.all(0.0),
                          child: IconButton(
                            iconSize: 50,
                            icon: Image.asset(
                                'assets/images/Subtraction 5@3x.png'),
                          ),
                        ))
                    : Container()),
            Positioned(
                child: (!widget.search)
                    ? Align(
                        alignment: Alignment(-1.0, 0.1),
                        child: Container(
                          padding: EdgeInsets.only(left: 30.0, bottom: 20.0),
                          margin: EdgeInsets.all(0.0),
                          child: Text(
                            '${quiz.percentage}%',
                            style: TextStyle(
                                fontSize: 28, color: Color(0xffc5e2ec)),
                          ),
                        ))
                    : Container())
          ]),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                    width: 25,
                    color: Colors.transparent,
                  ),
                  Text(
                    quiz.title,
                    style: headerTextStyle(),
                  ),
                  Text(" (", style: regularTextStyle()),
                  Text(
                    '${quiz.count}',
                    style: regularTextStyle(),
                  ),
                  Text(") ", style: regularTextStyle()),
                ]),
                Row(
                  children: <Widget>[
                    Container(
                      width: 25,
                      color: Colors.transparent,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(
                          quiz.description,
                          style: subHeaderTextStyle(),
                        )),
                  ],
                )
              ]),
        ],
      ),
    ));
  }

  Widget FolderWidget() {
    return Container(
        height: 128.0,
        margin: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 10.0,
        ),
        child: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                FolderCard(),
                FolderCardContent(),
                GestureDetector(onTap: () {
                  titleBloc.updateDates(widget.userName);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QuizListView(
                            id: quiz.pk,
                            search: widget.search,
                            update: false,
                            userName: widget.userName,
                            title: quiz)),
                  );
                })
              ],
            ),
            (widget.update && !widget.longPress)
                ? Container(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 36,
                        child: IconButton(
                          padding: EdgeInsets.only(top: 21.0),
                          icon: Icon(
                            quiz.toggle == 1 ? Icons.thumb_up : Icons.thumb_up,
                            color: quiz.toggle == 1
                                ? Colors.black
                                : Colors.blueGrey,
                            size: quiz.toggle == 1 ? 18 : 18,
                          ),
                          onPressed: () {
                            updateLikes();
                          },
                        ),
                      ),
                      Container(
                        height: 43,
                        padding: const EdgeInsets.only(
                            top: 27.4, right: 14, left: 0),
                        child: Center(
                          child: Text(quiz.likes.toString()),
                        ),
                      ),
                    ],
                  ))
                : Container(),
            (!widget.search && !widget.longPress)
                ? Positioned(
                    child: updateFlag
                        ? Align(
                            alignment: Alignment(1.0, 0.9),
                            child: IconButton(
                              alignment: Alignment.bottomCenter,
                              icon: Icon(Icons.fiber_new),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QuizListView(
                                            id: quiz.pk,
                                            title: quiz,
                                            update: true,
                                            search: true,
                                            userName: widget.userName,
                                          )),
                                );
                              },
                            ))
                        : Container(),
                  )
                : Container(),
          ],
        ));
  }

  Widget QuizWidget() {
    return Container(
        height: 128.0,
        margin: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 10.0,
        ),
        child: Stack(
          children: <Widget>[
            Stack(
              children: <Widget>[
                QuizCard(),
                QuizCardContent(),
                widget.longPress
                    ? Container()
                    : GestureDetector(
                        onTap: () => {
                              if (!widget.search)
                                {
                                  titleBloc.updateDates(widget.userName),
                                  date = DateFormat('yyyy-MM-dd HH:mm:ss')
                                      .format(DateTime.now()),
                                  quiz.studyDate = date,
                                  titleBloc.updateTitles(quiz),
                                },
                              if (user.study == 0 && !widget.search)
                                {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TutorialView(
                                            pageNum: 2,
                                            title: widget.title,
                                            list: list)),
                                  )
                                  /*Navigator.pushAndRemoveUntil(context,
                                      MaterialPageRoute(
                                    builder: (context) {
                                      return TutorialView(
                                          pageNum: 2,
                                          title: widget.title,
                                          list: list);
                                    },
                                  ), (route) => false)*/
                                }
                              else
                                {
                                  widget.search
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  DownloadView(
                                                      newTitle: widget.title,
                                                      update: false,
                                                      folder:
                                                          widget.searchFolder)),
                                        )
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  QuizStartView(
                                                      title: widget.title,
                                                      dbList: list)),
                                        )
                                },
                            })
              ],
            ),
            (!widget.search && !widget.longPress)
                ? Container(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 36,
                        child: IconButton(
                          padding: EdgeInsets.only(top: 2.0),
                          icon: Icon(
                            quiz.toggle == 1 ? Icons.thumb_up : Icons.thumb_up,
                            color: quiz.toggle == 1
                                ? Colors.black
                                : Colors.blueGrey,
                            size: quiz.toggle == 1 ? 18 : 18,
                          ),
                          onPressed: () {
                            updateLikes();
                          },
                        ),
                      ),
                      Container(
                        height: 36,
                        padding:
                            const EdgeInsets.only(top: 15, right: 14, left: 0),
                        child: Center(
                          child: Text(quiz.likes.toString()),
                        ),
                      ),
                    ],
                  ))
                : Container(),
            (widget.update && !widget.longPress)
                ? Positioned(
                    child: updateFlag
                        ? Align(
                            alignment: Alignment(1.0, 0.9),
                            child: IconButton(
                              alignment: Alignment.bottomCenter,
                              icon: Icon(Icons.fiber_new),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DownloadView(
                                          newTitle: newTitle,
                                          update: true,
                                          folder: widget.searchFolder)),
                                );
                              },
                            ))
                        : Container(),
                  )
                : Container(),
          ],
        ));
  }

  void getQuizList(int pk) async {
    if (widget.search) {
      list = await getQuiz(pk);
    } else {
      list = await TestDBHelper().getTestList(pk);
    }
  }

  void getCardTitle(int pk) async {
    dbTitle = await DBHelper().getCardTitle(pk);
  }

  void checkServer(CardTitle cardTitle) async {
    DateTime oldTime;
    DateTime newTime;
    if (widget.searchFolder) {
      newTitle = await DBHelper().getCardTitle(cardTitle.pk);
    } else {
      newTitle = await getCard(cardTitle.pk);
      titleBloc.updateLike(cardTitle.pk, newTitle.likes);
    }
    oldTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(cardTitle.date);
    newTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(newTitle.date);
    print(oldTime);
    print(newTime);
    result = oldTime.compareTo(newTime);
    if (widget.searchFolder) {
      if (newTitle.getUpdate == 0) result = 0;
    } else {
      if (cardTitle.getUpdate == 0) result = 0;
      if (cardTitle.userName == widget.userName) result = 0;
    }
    if (result == 0)
      updateFlag = false;
    else {
      updateFlag = true;
      cardTitle.newFlag = 1;
      await titleBloc.updateNewFlag(cardTitle.pk, 1);
      print(updateFlag);
    }
  }

  void updateLikes() async {
    await likes(quiz.pk, quiz.toggle);
    quiz.likes = quiz.likes + quiz.toggle;
    quiz.toggle = quiz.toggle * -1;
    await titleBloc.updateTitles(quiz);
    setState(() {});
  }

  void getUserInfo() async {
    user = await LoginDBHelper().getDate();
  }
}

class LongPressQuizView extends StatefulWidget {
  final CardTitle title;
  final String id;
  const LongPressQuizView({Key key, this.title, this.id}) : super(key: key);

  @override
  LongPressQuizViewState createState() => LongPressQuizViewState();
}

class LongPressQuizViewState extends State<LongPressQuizView>
    with SingleTickerProviderStateMixin {
  CardTitle quiz;
  bool type;
  int num = 0;
  List<TestList> list = List<TestList>();
  @override
  void initState() {
    super.initState();
    getQuizList(widget.title.pk);
    quiz = widget.title;
    num = list.length;
    if (quiz.dbFolder == 1)
      type = false;
    else
      type = true;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (list.length == 0) setState(() {});
    });
    return (type) ? QuizWidget() : FolderWidget();
  }

  FolderCard() {
    return Container(
      height: 115.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        vertical: 7.0,
      ),
      child: _folder(),
    );
  }

  _folder() {
    return SizedBox(
      width: 343.0,
      height: 98.0,
      child: Stack(
        children: <Widget>[
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 0.0, 343.0, 98.4),
            size: Size(343.0, 98.4),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            pinBottom: true,
            child: SvgPicture.string(
              '<svg viewBox="16.0 179.7 343.0 98.4" ><defs><linearGradient id="gradient" x1="0.5" y1="0.069803" x2="0.5" y2="0.266693"><stop offset="0.0" stop-color="#ffbcd5e9"  /><stop offset="1.0" stop-color="#ff89b3d5"  /></linearGradient></defs><path transform="translate(16.0, 179.67)" d="M 6.00029993057251 98.42940521240234 C 2.686500072479248 98.42940521240234 0 95.74290466308594 0 92.42910003662109 L 0 13.14360046386719 L 0 6.00029993057251 C 0 2.686500072479248 2.686500072479248 0 6.00029993057251 0 L 72 0 C 75.31380462646484 0 77.99940490722656 2.686500072479248 77.99940490722656 6.00029993057251 L 77.99940490722656 7.14330005645752 L 336.9996032714844 7.14330005645752 C 340.3134155273438 7.14330005645752 342.9999084472656 9.829800605773926 342.9999084472656 13.14360046386719 L 342.9999084472656 92.42910003662109 C 342.9999084472656 95.74290466308594 340.3134155273438 98.42940521240234 336.9996032714844 98.42940521240234 L 6.00029993057251 98.42940521240234 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 12.1, 343.0, 86.3),
            size: Size(343.0, 98.4),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            pinBottom: true,
            child: SvgPicture.string(
              '<svg viewBox="16.0 191.8 343.0 86.3" ><defs><linearGradient id="gradient" x1="0.351281" y1="0.113246" x2="0.733405" y2="0.911175"><stop offset="0.0" stop-color="#ffbcd5e9"  /><stop offset="1.0" stop-color="#ffcee1f0"  /></linearGradient></defs><path transform="translate(906.0, 166.81)" d="M -553.00048828125 111.2850036621094 L -806.6016235351562 111.2850036621094 L -883.9998168945312 111.2850036621094 C -887.3135986328125 111.2850036621094 -890.0001220703125 108.598503112793 -890.0001220703125 105.2856063842773 L -890.0001220703125 37.90530014038086 C -890.0001220703125 34.59149932861328 -887.3135986328125 31.90500068664551 -883.9998168945312 31.90500068664551 L -816.3013305664062 31.90500068664551 L -811.288330078125 27.25362205505371 C -810.1890258789062 25.87994384765625 -808.4981689453125 25.00020027160645 -806.6016235351562 25.00020027160645 L -553.00048828125 25.00020027160645 C -549.6867065429688 25.00020027160645 -547.0001831054688 27.68580055236816 -547.0001831054688 30.99960136413574 L -547.0001831054688 105.2856063842773 C -547.0001831054688 105.4538345336914 -547.0071411132812 105.6204452514648 -547.0206909179688 105.7851791381836 C -547.274658203125 108.8644104003906 -549.8549194335938 111.2850036621094 -552.9996337890625 111.2850036621094 Z" fill="url(#gradient)" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }

  QuizCard() {
    return Container(
        height: 115.0,
        margin: EdgeInsets.symmetric(vertical: 7.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Rectangle 76@3x.png'),
            fit: BoxFit.fill,
          ),
        ));
  }

  QuizCardContent() {
    return Container(
        child: Container(
      constraints: BoxConstraints.expand(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Stack(children: [
            Positioned(
                child: Align(
                    alignment: Alignment(-1.0, 0.0),
                    child: Container(
                      padding: EdgeInsets.all(0.0),
                      margin: EdgeInsets.all(0.0),
                      child: IconButton(
                        iconSize: 50,
                        icon: Image.asset('assets/images/Ellipse 3@3x.png'),
                      ),
                    ))),
            Positioned(
                child: Align(
                    alignment: Alignment(-1.0, 0.1),
                    child: Container(
                      padding: EdgeInsets.only(left: 30.0, bottom: 20.0),
                      margin: EdgeInsets.all(0.0),
                      child: Text(
                        '${quiz.percentage}' '%',
                        style:
                            TextStyle(fontSize: 28, color: Color(0xffa0c7e4)),
                      ),
                    )))
          ]),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                    width: 25,
                    color: Colors.transparent,
                  ),
                  Text(
                    quiz.title,
                    style: headerTextStyle(),
                  ),
                  Text(" (", style: regularTextStyle()),
                  Text(
                    '${quiz.count}',
                    style: regularTextStyle(),
                  ),
                  Text(") ", style: regularTextStyle()),
                ]),
                Row(
                  children: <Widget>[
                    Container(
                      width: 25,
                      color: Colors.transparent,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(
                          quiz.description,
                          style: subHeaderTextStyle(),
                        )),
                  ],
                )
              ]),
        ],
      ),
    ));
  }

  FolderCardContent() {
    return Container(
        child: Container(
      padding: EdgeInsets.only(top: 15),
      constraints: BoxConstraints.expand(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Stack(children: [
            Positioned(
                child: Align(
                    alignment: Alignment(-1.0, 0.0),
                    child: Container(
                      padding: EdgeInsets.all(0.0),
                      margin: EdgeInsets.all(0.0),
                      child: IconButton(
                        iconSize: 50,
                        icon: Image.asset('assets/images/Subtraction 5@3x.png'),
                      ),
                    ))),
            Positioned(
                child: Align(
                    alignment: Alignment(-1.0, 0.1),
                    child: Container(
                      padding: EdgeInsets.only(left: 30.0, bottom: 20.0),
                      margin: EdgeInsets.all(0.0),
                      child: Text(
                        '${quiz.percentage}%',
                        style:
                            TextStyle(fontSize: 28, color: Color(0xffc5e2ec)),
                      ),
                    )))
          ]),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(children: <Widget>[
                  Container(
                    width: 25,
                    color: Colors.transparent,
                  ),
                  Text(
                    quiz.title,
                    style: headerTextStyle(),
                  ),
                  Text(" (", style: regularTextStyle()),
                  Text(
                    '${quiz.count}',
                    style: regularTextStyle(),
                  ),
                  Text(") ", style: regularTextStyle()),
                ]),
                Container(
                  height: 7,
                  color: Colors.transparent,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 25,
                      color: Colors.transparent,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 3.0),
                        child: Text(
                          quiz.description,
                          style: subHeaderTextStyle(),
                        )),
                  ],
                )
              ]),
        ],
      ),
    ));
  }

  Widget FolderWidget() {
    return ShakeAnimatedWidget(
        child: Container(
      height: 120.0,
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: Stack(
        children: <Widget>[
          FolderCard(),
          FolderCardContent(),
        ],
      ),
    ));
  }

  Widget QuizWidget() {
    return ShakeAnimatedWidget(
        child: Container(
      height: 120.0,
      margin: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      child: Stack(
        children: <Widget>[
          QuizCard(),
          QuizCardContent(),
        ],
      ),
    ));
  }

  void getQuizList(int pk) async {
    list = await TestDBHelper().getTestList(pk);
  }
}
