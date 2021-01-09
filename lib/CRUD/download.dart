import 'package:flutter/material.dart';
import 'package:voicequiz/CRUD/textDesign.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:intl/intl.dart';
import 'package:voicequiz/top/SearchScreen.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:flutter/cupertino.dart';

class DownloadView extends StatefulWidget {
  final CardTitle newTitle;
  final bool update;
  final bool folder;
  const DownloadView({Key key, this.newTitle, this.update, this.folder})
      : super(key: key);
  @override
  _DownloadViewState createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {
  TitleBloc titleBloc = TitleBloc();
  TestBloc testBloc = TestBloc();
  int index = 0;
  CardTitle newTitle = CardTitle();
  CardTitle originTitle = CardTitle(title: "");
  List<TestList> list = List<TestList>();
  bool stateFlag = true;

  @override
  void initState() {
    super.initState();
    if (widget.update) getDbData(widget.newTitle.pk);
    newTitle = widget.newTitle;
  }

  @override
  void dispose() {
    titleBloc.dispose();
    testBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.update) {
        if (originTitle.title.isEmpty) setState(() {});
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 90,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Rectangle 40@3x.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Color(0xff5191c3),
                    onPressed: () {
                      if (widget.folder)
                        Navigator.pop(context);
                      else if (widget.update)
                        showUpdateAlertDialog(context);
                      else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Text("Download View",
                      style: TextStyle(fontSize: 30.0, fontFamily: 'namsan')),
                  widget.folder
                      ? Container(width: 36)
                      : IconButton(
                          icon: Icon(Icons.file_download,
                              color: Color(0xff5191c3)),
                          iconSize: 29,
                          onPressed: () {
                            print(widget.update);
                            showSaveAlertDialog(context);
                          }),
                ],
              ),
            ),
            Container(
              height: 15.0,
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/makecardwhite@3x.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      height: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/makecardgrey@3x.png'),
                        fit: BoxFit.fill,
                      )),
                      child: Container(
                        height: 40,
                        alignment: Alignment(0.0, 0.0),
                        child: Text("Title", style: TitleTextStyle),
                      )),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text('${widget.newTitle.title}'),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/makecardwhite@3x.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      height: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/makecardgrey@3x.png'),
                        fit: BoxFit.fill,
                      )),
                      child: Container(
                        height: 40,
                        alignment: Alignment(0.0, 0.0),
                        child: Text("Description", style: TitleTextStyle),
                      )),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text('${widget.newTitle.description}'),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: 10, right: 10),
              width: MediaQuery.of(context).size.width - 20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/makecardwhite@3x.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                      height: 40,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/makecardgrey@3x.png'),
                        fit: BoxFit.fill,
                      )),
                      child: Container(
                        height: 40,
                        alignment: Alignment(0.0, 0.0),
                        child: Text("Title", style: TitleTextStyle),
                      )),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    alignment: Alignment.center,
                    child: Text('${widget.newTitle.tag}'),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            showQuizList(widget.newTitle.pk),
          ],
        ),
      ),
    );
  }

  void showSaveAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              content: Builder(
                builder: (context) {
                  // Get available height and width of the build area of this widget. Make a choice depending on the size.
                  var height = MediaQuery.of(context).size.height;
                  var width = MediaQuery.of(context).size.width;
                  return Container(
                    width: width - 100,
                    alignment: Alignment.center,
                    child: Text("저장하시겠습니까?",
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        )),
                  );
                },
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("네",
                      style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                  onPressed: () {
                    downloadCard(newTitle.pk);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("아니요",
                      style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context, "아니요");
                  },
                ),
              ]);
        });
  }

  void downloadCard(int pk) async {
    newTitle = await getCard(pk);
    String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    if (widget.update == true) {
      newTitle.toggle = originTitle.toggle;
      newTitle.percentage = originTitle.percentage;
      newTitle.getUpdate = originTitle.getUpdate;
      newTitle.dbFolder = originTitle.dbFolder;
      newTitle.studyDate = date;
      testBloc.deleteQTestLists(pk);
    } else {
      newTitle.toggle = 1;
      newTitle.getUpdate = 1;
      newTitle.percentage = 0;
      if (newTitle.folder)
        newTitle.dbFolder = 1;
      else
        newTitle.dbFolder = 0;
      newTitle.studyDate = date;
    }
    newTitle.newFlag = 0;
    await titleBloc.updateTitles(newTitle);
    List<TestList> list = await getQuiz(pk);
    for (int i = 0; i < list.length; i++) {
      list[i].pk = pk;
      await testBloc.addTestLists(list[i]);
    }
    if (widget.update)
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return TodoListView();
        },
      ), (route) => false);
    else
      Navigator.pop(context);
  }

  showQuizList(int pk) {
    return FutureBuilder(
        future: getQuiz(pk),
        builder:
            (BuildContext context, AsyncSnapshot<List<TestList>> snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    TestList item = snapshot.data[index];
                    list = snapshot.data;
                    return Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: <Widget>[
                          Stack(
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width - 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 40,
                                      width: MediaQuery.of(context).size.width -
                                          20,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/makecardgrey@3x.png'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      alignment: Alignment(0.0, 0.0),
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TitleTextStyle,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            "Q.",
                                            style: TitleTextStyle,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(item.question),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        //
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xfff7f7f7),
                                                width: 3.0)),
                                      ),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            "A.",
                                            style: TitleTextStyle,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(item.answer),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                )
              : Center(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
        });
  }

  showUpdateAlertDialog(BuildContext context) async {
    await titleBloc.updateTitles(newTitle);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("뒤로 가시겠습니까?\n",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSans',
                    fontSize: 18,
                  )),
              content: Text("앞으로 업데이트 알림을 보내지 않습니다.\n",
                  style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontSize: 16,
                  )),
              actions: <Widget>[
                FlatButton(
                  child: Text("네",
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                    setUpdate();
                  },
                ),
                FlatButton(
                  child: Text("아니요",
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                      )),
                  onPressed: () {
                    Navigator.pop(context, "아니요");
                  },
                ),
              ]);
        });
  }

  void setUpdate() async {
    originTitle.getUpdate = 0;
    await titleBloc.updateTitles(originTitle);
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return TodoListView();
      },
    ), (route) => false);
  }

  getDbData(int pk) async {
    originTitle = await DBHelper().getCardTitle(pk);
  }
}

Widget title(BuildContext context, String title, String text) {
  return Container(
    padding: EdgeInsets.only(top: 7, bottom: 12, right: 15, left: 15),
    margin: EdgeInsets.only(left: 10, right: 10),
    width: MediaQuery.of(context).size.width - 20,
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 3,
          spreadRadius: 3,
          offset: Offset(3, 5),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TitleTextStyle,
        ),
        SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.grey[400],
          ),
          child: Text(text),
        ),
      ],
    ),
  );
}
