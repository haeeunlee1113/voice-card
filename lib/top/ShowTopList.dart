import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voicequiz/CRUD/textDesign.dart';
import 'package:voicequiz/top/QuizCard.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:voicequiz/top/SearchScreen.dart';
import 'package:voicequiz/top/ShakeAnimate.dart';
import 'package:voicequiz/top/Style.dart';
import 'package:voicequiz/CRUD/creation.dart';
import 'package:intl/intl.dart';
import 'package:voicequiz/CRUD/EditView.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/svg.dart';
import 'package:adobe_xd/blend_mask.dart';
import 'package:progress_dialog/progress_dialog.dart';

bool checkIndex(int index, int length) {
  if ((index + 1) % 3 == 0)
    return true;
  else {
    if ((index + 1) == length) return true;
  }
  return false;
}

class TodoListView extends StatefulWidget {
  TodoListView({Key key}) : super(key: key);
  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<TodoListView> with TickerProviderStateMixin {
  TitleBloc titleBloc = TitleBloc();
  TestBloc testBloc = TestBloc();
  var button = true;
  var flag = true;
  List<CardTitle> list = List<CardTitle>();
  String id = "";
  bool pressFlag = false;
  CardTitle newTitle;
  List<CardTitle> originList = List<CardTitle>();

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (id.isEmpty) setState(() {});
    });
    return Scaffold(
      body: Stack(children: <Widget>[
        Container(
          height: 100.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(
            vertical: 5.0,
            horizontal: 24.0,
          ),
        ),
        NormalViewBuild(),
      ]),
    );
  }

  void getUserId() async {
    id = await getId();
  }

  Widget NormalViewBuild() {
    CardTitle item;
    return FutureBuilder(
        future: DBHelper().getAllCardTitle(),
        builder:
            (BuildContext context, AsyncSnapshot<List<CardTitle>> snapshot) {
          if (snapshot.hasData) list = snapshot.data;
          return snapshot.hasData
              ? GestureDetector(
                  onLongPress: () {
                    titleBloc.updateDates(id);
                    setState(() {
                      pressFlag = true;
                    });
                  },
                  child: ListView(children: <Widget>[
                    Container(
                        height: 100.0,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 12.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.only(top: 10.0),
                                height: 90.0,
                                child: Center(
                                    child: Text(
                                  "Voice FlashCard",
                                  style: TextStyle(
                                    fontSize: 30.0,
                                    fontFamily: 'namsan',
                                  ),
                                  textAlign: TextAlign.center,
                                ))),
                            Container(width: 60.0, color: Colors.transparent),
                            pressFlag
                                ? Stack(
                                    alignment: Alignment(0.0, 0.0),
                                    children: <Widget>[
                                        Positioned(
                                          child: Transform.scale(
                                            scale: 1.4,
                                            child: IconButton(
                                              padding:
                                                  EdgeInsets.only(top: 10.0),
                                              icon: Image.asset(
                                                  'assets/images/newpath.png'),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 19.0,
                                          left: 9.3,
                                          child: Stack(children: <Widget>[
                                            Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    pressFlag = false;
                                                  });
                                                },
                                                child: Text("완료",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.0,
                                                      fontFamily: 'NotoSans',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    )),
                                              ),
                                            ),
                                          ]),
                                        )
                                      ])
                                : Hero(
                                    tag: 'imageHero',
                                    child: GestureDetector(
                                      onTap: () {
                                        titleBloc.updateDates(id);
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (_, __, ___) =>
                                                SearchList(),
                                          ),
                                        ).then((value) => setState(() {}));
                                      },
                                      child: Transform.scale(
                                          scale: 1,
                                          child: Container(
                                            padding: EdgeInsets.only(
                                              top: 5.0,
                                            ),
                                            child: _searchButton(),
                                          )),
                                    ))
                          ],
                        )),
                    ListView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          //list = snapshot.data;
                          print("여기");
                          print(list[index].pk);
                          item = snapshot.data[index];
                          return Column(
                            key: ValueKey(list[index].pk),
                            children: <Widget>[
                              snapshot.data.length == 0
                                  ? Container(
                                      height: 115.0,
                                      margin: EdgeInsets.symmetric(
                                        vertical: 7.0,
                                      ),
                                      color: Colors.white,
                                      child: AdmobBanner(
                                        adUnitId: getBannerAdInitId(),
                                        adSize: AdmobBannerSize.LARGE_BANNER,
                                      ))
                                  : Container(),
                              Stack(
                                children: [
                                  pressFlag
                                      ? buildBody(index, list[index].pk)
                                      : NormalQuizView(
                                          title: item,
                                          search: false,
                                          userName: id,
                                          searchFolder: false,
                                          update: true,
                                          longPress: false),
                                  pressFlag
                                      ? ShakeAnimatedWidget(
                                          child: Container(
                                            alignment: Alignment.topRight,
                                            padding: EdgeInsets.only(
                                                top: 11.0, right: 3.0),
                                            height: 50.0,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  Container(
                                                      child: showAlertDialog(
                                                          context,
                                                          index,
                                                          list[index]));
                                                });
                                              },
                                              child: Container(
                                                color: Colors.transparent,
                                                width: 25,
                                                height: 25,
                                                padding: EdgeInsets.all(4),
                                                child: Transform.scale(
                                                  scale: 1.2,
                                                  child: _deleteButton(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  (id == list[index].userName && pressFlag)
                                      ? Positioned(
                                          child: ShakeAnimatedWidget(
                                            child: Container(
                                              width: 34,
                                              height: 34,
                                              child: IconButton(
                                                icon: Image.asset(
                                                    'assets/images/modify@3x.png'),
                                                onPressed: () {
                                                  list[index].tag = list[index]
                                                      .tag
                                                      .replaceAll(" ", "#");
                                                  if (list[index].dbFolder ==
                                                      1) {
                                                    folderSaveDialog(
                                                        context,
                                                        list[index],
                                                        -1,
                                                        -1,
                                                        list[index]);
                                                  } else {
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                      builder: (context) {
                                                        return EditView(
                                                          num: list[index].pk,
                                                          newTitle: list[index],
                                                        );
                                                      },
                                                    ), (route) => false);
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          right: 4,
                                          bottom: 15,
                                        )
                                      : Container(),
                                ],
                              ),
                              checkIndex(index, list.length)
                                  ? Container(
                                      height: 115.0,
                                      margin: EdgeInsets.symmetric(
                                        vertical: 7.0,
                                      ),
                                      color: Colors.white,
                                      child: AdmobBanner(
                                        adUnitId: getBannerAdInitId(),
                                        adSize: AdmobBannerSize.LARGE_BANNER,
                                      ))
                                  : Container(),
                            ],
                          );
                        }),
                    GestureDetector(
                      onTap: () {
                        titleBloc.updateDates(id);
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                          builder: (context) {
                            return CreationView();
                          },
                        ), (route) => false);
                      },
                      child: Container(
                          height: 50.0,
                          margin: EdgeInsets.symmetric(
                            vertical: 5.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/FOLDER@3x.png'),
                              fit: BoxFit.fill,
                            ),
                          )),
                    ),
                  ]))
              : Center(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
        });
  }

  _searchButton() {
    return // Adobe XD layer: 'add' (group)
        SizedBox(
      width: 47.0,
      height: 47.0,
      child: Stack(
        children: <Widget>[
          Pinned.fromSize(
            bounds: Rect.fromLTWH(0.0, 0.0, 47.0, 47.0),
            size: Size(47.0, 47.0),
            pinLeft: true,
            pinRight: true,
            pinTop: true,
            pinBottom: true,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                gradient: LinearGradient(
                  begin: Alignment(0.0, -1.0),
                  end: Alignment(0.0, 1.0),
                  colors: [const Color(0xffb3d4ee), const Color(0xff3787c3)],
                  stops: [0.0, 1.0],
                ),
                border: Border.all(width: 3.0, color: const Color(0xffffffff)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x29000000),
                    offset: Offset(0, 0),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Pinned.fromSize(
            bounds: Rect.fromLTWH(13.0, 12.0, 20.4, 20.9),
            size: Size(47.0, 47.0),
            fixedWidth: true,
            fixedHeight: true,
            child:
                // Adobe XD layer: 'search' (group)
                BlendMask(
              blendMode: BlendMode.srcOver,
              child: Stack(
                children: <Widget>[
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(0.0, 0.0, 19.0, 20.0),
                    size: Size(20.4, 20.9),
                    pinLeft: true,
                    pinRight: true,
                    pinTop: true,
                    pinBottom: true,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.elliptical(9999.0, 9999.0)),
                        border: Border.all(
                            width: 3.0, color: const Color(0xffffffff)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0x29000000),
                            offset: Offset(0, 3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Pinned.fromSize(
                    bounds: Rect.fromLTWH(15.5, 16.0, 4.9, 4.9),
                    size: Size(20.4, 20.9),
                    pinRight: true,
                    pinBottom: true,
                    fixedWidth: true,
                    fixedHeight: true,
                    child: SvgPicture.string(
                      '<svg viewBox="15.8 15.8 4.9 4.9" ><defs><filter id="shadow"><feDropShadow dx="0" dy="3" stdDeviation="6"/></filter></defs><path transform="translate(15.75, 15.75)" d="M 0 0 L 4.871606826782227 4.871600151062012" fill="none" stroke="#ffffff" stroke-width="3" stroke-miterlimit="4" stroke-linecap="round" filter="url(#shadow)"/></svg>',
                      allowDrawingOutsideViewBox: true,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _deleteButton() {
    const String _svg_frf616 =
        '<svg viewBox="347.8 486.1 5.4 5.4" ><path transform="translate(347.76, 486.09)" d="M 0 5.366857528686523 L 5.366857528686523 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>';
    const String _svg_ld73re =
        '<svg viewBox="347.8 486.1 5.4 5.4" ><path transform="translate(347.76, 486.09)" d="M 0 0 L 5.366857528686523 5.366857528686523" fill="none" stroke="#ffffff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>';

    return Stack(
      children: <Widget>[
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 19.0, 19.0),
          size: Size(19.0, 19.0),
          pinLeft: true,
          pinRight: true,
          pinTop: true,
          pinBottom: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.0),
              color: const Color(0xff6a6e70),
            ),
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(6.8, 6.9, 5.4, 5.4),
          size: Size(19.0, 19.0),
          fixedWidth: true,
          fixedHeight: true,
          child: SvgPicture.string(
            _svg_frf616,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(6.8, 6.9, 5.4, 5.4),
          size: Size(19.0, 19.0),
          fixedWidth: true,
          fixedHeight: true,
          child: SvgPicture.string(
            _svg_ld73re,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  void delete(CardTitle title) async {
    if (title.dbFolder == 1) {
      await titleBloc.deleteFolders(title.pk);
    } else {
      await testBloc.deleteQTestLists(title.pk);
      await titleBloc.deleteCard(title.pk);
    }
    setState(() {});
    Navigator.pop(context);
  }

  showAlertDialog(BuildContext context, int index, CardTitle title) {
    Container();
    Widget cancelButton = FlatButton(
      child: Text(
        "네",
        style: TextStyle(fontFamily: 'NotoSans', fontSize: 16),
      ),
      onPressed: () {
        delete(title);
      },
    );
    Widget continueButton = FlatButton(
      child: Container(
        alignment: Alignment.center,
        child:
            Text("아니요", style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
      ),
      onPressed: () => {
        Navigator.pop(context),
      },
    );

    // set up the AlertDialog
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      content: Builder(
        builder: (context) {
          var width = MediaQuery.of(context).size.width;
          return Container(
            //height: height - 600,
            width: width - 100,
            alignment: Alignment.center,
            child: Text("삭제하시겠습니까?",
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          );
        },
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget buildBody(int index, int pk) {
    Draggable draggable = Draggable<CardTitle>(
        data: (list[index].dbFolder == 0 && list[index].userName == id)
            ? list[index]
            : null,
        axis: Axis.vertical,
        maxSimultaneousDrags: 1,
        child: GestureDetector(
            child: LongPressQuizView(title: list[index], id: id)),
        feedback: Material(
            color: Colors.transparent,
            child: Center(
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width),
                    child: Center(
                      child: Container(
                          child: Transform.scale(
                              scale: 1, child: DragQuizCard(index))),
                    )))));

    return DragTarget<CardTitle>(
        key: UniqueKey(),
        onWillAccept: (cardorder) {
          if (cardorder.dbFolder == 0 && list[index].userName == id) if (list
                  .indexOf(cardorder) !=
              index) {
            return true;
          }
          return false; // 선택한 cardorder의 index가 변경되면
        },
        onAccept: (cardorder) {
          setState(() {
            var firstIndex = list.indexOf(cardorder);
            if (list[index].dbFolder == 0) {
              newTitle = CardTitle(
                title: "",
                description: "",
                tag: "#",
                pk: 0,
                dbFolder: 1,
                likes: 0,
                percentage: ((cardorder.count + list[index].count) / 2).round(),
                toggle: 1,
                count: cardorder.count + list[index].count,
                id: 0,
                newFlag: 0,
              );
              folderSaveDialog(context, newTitle, firstIndex, index, cardorder);
            } else {
              addDbFolder(index, firstIndex);
            }
          });
        },
        builder: (BuildContext context, List<CardTitle> candidateData,
            List<dynamic> rejectedData) {
          return Container(
              child: candidateData.isEmpty &&
                      list[index].dbFolder == 0 &&
                      list[index].userName == id
                  ? draggable
                  : LongPressQuizView(title: list[index], id: id));
        });
  }

  Widget DragQuizCard(int index) {
    return Container(
      alignment: Alignment.center,
      height: 100,
      width: 250,
      //margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Rectangle 76@3x.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Container(
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
                          '${list[index].percentage}' '%',
                          style:
                              TextStyle(fontSize: 20, color: Color(0xffa0c7e4)),
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
                      list[index].title,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 18,
                      ),
                    ),
                    Text(" (",
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 15,
                        )),
                    Text(
                      '${list[index].count}',
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 15,
                      ),
                    ),
                    Text(") ",
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 15,
                        )),
                  ]),
                  Container(
                    width: 10,
                    color: Colors.transparent,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 25,
                        color: Colors.transparent,
                      ),
                      Text(list[index].description,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 11,
                          )),
                    ],
                  )
                ]),
          ],
        ),
      )),
    );
  }

  addDbFolder(int index, int firstIndex) async {
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(message: "Please wait...");
    await pr.show();
    await addFolder(list[index].pk, list[firstIndex], list[index], false);
    await pr.hide();
    setState(() {});
  }

  folderSaveDialog(BuildContext context, CardTitle newTitle, int firstIndex,
      int index, CardTitle cardorder) async {
    TextEditingController titleController =
        new TextEditingController(text: newTitle.title);
    TextEditingController desController =
        new TextEditingController(text: newTitle.description);
    TextEditingController tagController =
        new TextEditingController(text: newTitle.tag);
    int length = 0;
    FocusNode titleFocus = FocusNode();
    FocusNode desFocus = FocusNode();
    FocusNode tagFocus = FocusNode();
    final find = ' ';
    final replaceWith = '#';
    tagController.addListener(() {
      if (tagController.text.isEmpty) {
        tagController.text = "#";
        tagController.selection = TextSelection.fromPosition(
          TextPosition(offset: tagController.text.length),
        );
      }
      if (tagController.text.contains(" ") ||
          tagController.text.contains(",")) {
        length = tagController.text.length - 1;
        if (tagController.text[length - 1] == "#") {
          tagController.text = tagController.text.substring(0, length);
        } else if (tagController.text.contains(" "))
          tagController.text = tagController.text.replaceAll(find, replaceWith);
        else {
          tagController.text = tagController.text.replaceAll(',', replaceWith);
        }
        tagController.selection = TextSelection.fromPosition(
          TextPosition(offset: tagController.text.length),
        );
      }
    });
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
              child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/makecardwhite@3x.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/makecardgrey@3x.png'),
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
                              child: TextFormField(
                                autofocus: true,
                                controller: titleController,
                                keyboardType: TextInputType.multiline,
                                focusNode: titleFocus,
                                onFieldSubmitted: (term) {
                                  titleFocus.unfocus();
                                  FocusScope.of(context).requestFocus(desFocus);
                                },
                                textInputAction: TextInputAction.go,
                                maxLines: null,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(7),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/makecardwhite@3x.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/makecardgrey@3x.png'),
                                  fit: BoxFit.fill,
                                )),
                                child: Container(
                                  alignment: Alignment(0.0, 0.0),
                                  child: Text("Description",
                                      style: TitleTextStyle),
                                )),
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: TextFormField(
                                controller: desController,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.go,
                                focusNode: desFocus,
                                onFieldSubmitted: (term) {
                                  desFocus.unfocus();
                                  FocusScope.of(context).requestFocus(tagFocus);
                                },
                                maxLines: null,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(7),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 7),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image:
                              AssetImage('assets/images/makecardgrey@3x.png'),
                          fit: BoxFit.fill,
                        )),
                        alignment: Alignment(0.0, 0.0),
                        child: Text("HashTags", style: TitleTextStyle),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.transparent,
                        ),
                        child: TextFormField(
                          controller: tagController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          maxLines: null,
                          focusNode: tagFocus,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(7),
                          ),
                        ),
                      ),
                      SizedBox(height: 7),
                      RaisedButton(
                        onPressed: () {
                          length = tagController.text.length - 1;
                          newTitle.tag = tagController.text;
                          if (newTitle.tag[length] == "#") {
                            newTitle.tag = newTitle.tag.substring(0, length);
                          }
                          newTitle.title = titleController.text;
                          newTitle.description = desController.text;
                          newTitle.tag =
                              newTitle.tag.replaceAll(replaceWith, find);
                          if (length == 0) newTitle.tag = "";
                          if (newTitle.title.isEmpty ||
                              newTitle.description.isEmpty ||
                              newTitle.tag.isEmpty) {
                            showBlankAlertDialog(context);
                          } else {
                            if (firstIndex == -1) {
                              updateFolder(cardorder);
                            } else {
                              Navigator.pop(context);
                              saveFolder(firstIndex, index);
                            }
                          }
                        },
                        child: Text("저장", style: TitleTextStyle),
                      )
                    ],
                  )));
        });
  }

  void showBlankAlertDialog(BuildContext context) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("채워지지 않은 항목이 있습니다",
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            actions: <Widget>[
              FlatButton(
                child: Text("닫기",
                    style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  void saveFolder(int firstIndex, int index) async {
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(message: "Please wait...");
    await pr.show();
    await makeFolderCard(newTitle, list[firstIndex], list[index]);
    await pr.hide();
    setState(() {});
  }

  void updateFolder(CardTitle cardTitle) async {
    await updateFolderCard(cardTitle);
    setState(() {
      Navigator.pop(context);
    });
  }
}

class QuizListView extends StatefulWidget {
  final int id;
  final String userName;
  final bool search;
  final CardTitle title;
  final bool update;
  const QuizListView(
      {Key key, this.id, this.userName, this.search, this.title, this.update})
      : super(key: key);
  @override
  QuizListViewState createState() => QuizListViewState();
}

class QuizListViewState extends State<QuizListView>
    with TickerProviderStateMixin {
  CardTitle newTitle;
  QCardBloc qCardBloc;
  TitleBloc titleBloc = TitleBloc();
  TestBloc testBloc = TestBloc();
  CardTitle originTitle = CardTitle(title: "");
  List<CardTitle> list = List<CardTitle>();
  bool editFlag = false;
  @override
  void initState() {
    super.initState();
    newTitle = widget.title;
    if (widget.update) getDbData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.search ? NormalSearchViewBuild() : NormalViewBuild(),
    );
  }

  Widget NormalViewBuild() {
    //CardTitle item;
    return FutureBuilder(
        future: DBHelper().getQCardTitle(widget.id),
        builder:
            (BuildContext context, AsyncSnapshot<List<CardTitle>> snapshot) {
          if (snapshot.hasData) list = snapshot.data;
          print("리로드");
          return snapshot.hasData
              ? ListView(children: <Widget>[
                  Container(
                    height: 55.0,
                    padding: EdgeInsets.only(right: 20),
                    alignment: Alignment(0.0, 0.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/Rectangle 40@3x.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          color: Color(0xff5191c3),
                          onPressed: () {
                            widget.search
                                ? Navigator.pop(context)
                                : Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(
                                    builder: (context) {
                                      return TodoListView();
                                    },
                                  ), (route) => false);
                          },
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25.0),
                          child: Text(widget.title.title,
                              style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 27.0,
                                  fontWeight: FontWeight.w700)),
                        ),

                        editFlag
                            ? Stack(children: <Widget>[
                                Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(bottom: 4),
                                        height: 30,
                                        width: 50,
                                      ),
                                      Transform.scale(
                                        scale: 1.4,
                                        child: IconButton(
                                          padding: EdgeInsets.only(top: 2.0),
                                          icon: Image.asset(
                                              'assets/images/newpath.png'),
                                        ),
                                      ),
                                    ]),
                                Positioned(
                                  top: 12.0,
                                  left: 10.0,
                                  child: Container(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            editFlag = false;
                                          });
                                        },
                                        child: Text("완료",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontFamily: 'NotoSans',
                                              fontWeight: FontWeight.w700,
                                            )),
                                      ),
                                    ),
                                  ),
                                )
                              ])
                            : Container(
                                height: 30,
                                width: 50,
                              ),
                        //SizedBox(height: 1),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ListView.builder(
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                editFlag = true;
                              });
                            },
                            child: Container(
                                key: UniqueKey(),
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        editFlag
                                            ? NormalQuizView(
                                                title: snapshot.data[index],
                                                search: false,
                                                userName: widget.userName,
                                                searchFolder: false,
                                                update: false,
                                                longPress: true)
                                            : NormalQuizView(
                                                title: snapshot.data[index],
                                                search: false,
                                                userName: widget.userName,
                                                searchFolder: false,
                                                update: true,
                                                longPress: false),
                                        editFlag
                                            ? Container(
                                                alignment: Alignment.topRight,
                                                padding: EdgeInsets.only(
                                                    top: 11.0, right: 3.0),
                                                height: 50.0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      Container(
                                                          child:
                                                              showAlertDialog(
                                                                  context,
                                                                  index,
                                                                  list[index]));
                                                    });
                                                  },
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    width: 25,
                                                    height: 25,
                                                    padding: EdgeInsets.all(4),
                                                    child: Transform.scale(
                                                      scale: 1.2,
                                                      child: _deleteButton(),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        widget.userName ==
                                                    list[index].userName &&
                                                editFlag
                                            ? Positioned(
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  child: IconButton(
                                                      icon: Image.asset(
                                                          'assets/images/modify@3x.png'),
                                                      onPressed: () {
                                                        Navigator
                                                            .pushAndRemoveUntil(
                                                                context,
                                                                MaterialPageRoute(
                                                          builder: (context) {
                                                            return EditView(
                                                              num: list[index]
                                                                  .pk,
                                                              newTitle:
                                                                  list[index],
                                                              folderTitle:
                                                                  widget.title,
                                                            );
                                                          },
                                                        ), (route) => false);
                                                      }),
                                                ),
                                                right: 4,
                                                bottom: 15,
                                              )
                                            : Container(),
                                      ],
                                    ),
                                    checkIndex(index, list.length)
                                        ? Container(
                                            height: 115.0,
                                            margin: EdgeInsets.symmetric(
                                              vertical: 7.0,
                                            ),
                                            color: Colors.white,
                                            child: AdmobBanner(
                                              adUnitId: getBannerAdInitId(),
                                              adSize:
                                                  AdmobBannerSize.LARGE_BANNER,
                                            ))
                                        : Container(),
                                  ],
                                ))
                            //NormalQuizView(title: snapshot.data[index], search: false, userName : widget.userName, searchFolder: false, update: true, longPress: false),

                            );
                      })
                ])
              : Center(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                );
        });
  }

  Widget NormalSearchViewBuild() {
    return FutureBuilder(
        future: getFolder(widget.id),
        builder:
            (BuildContext context, AsyncSnapshot<List<CardTitle>> snapshot) {
          return snapshot.hasData
              ? ListView(
                  children: <Widget>[
                    Container(
                      height: 60.0,
                      alignment: Alignment(0.0, 0.0),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/Rectangle 40@3x.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios),
                            color: Color(0xff5191c3),
                            onPressed: () {
                              if (widget.search) {
                                if (widget.update) {
                                  showUpdateAlertDialog(context);
                                } else {
                                  Navigator.pop(context);
                                }
                              } else {
                                Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(
                                  builder: (context) {
                                    return TodoListView();
                                  },
                                ), (route) => false);
                              }
                            },
                          ),
                          Text(widget.title.title,
                              style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 27.0)),
                          IconButton(
                              padding: EdgeInsets.only(top: 10),
                              icon: Icon(Icons.file_download),
                              iconSize: 29,
                              color: Color(0xff5191c3),
                              onPressed: () {
                                showSaveAlertDialog(context);
                              })
                        ],
                      ),
                    ),
                    ListView.builder(
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return NormalQuizView(
                            title: snapshot.data[index],
                            update: widget.update,
                            search: true,
                            userName: widget.userName,
                            searchFolder: true,
                            longPress: false,
                          );
                        }),
                  ],
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

  _deleteButton() {
    const String _svg_frf616 =
        '<svg viewBox="347.8 486.1 5.4 5.4" ><path transform="translate(347.76, 486.09)" d="M 0 5.366857528686523 L 5.366857528686523 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>';
    const String _svg_ld73re =
        '<svg viewBox="347.8 486.1 5.4 5.4" ><path transform="translate(347.76, 486.09)" d="M 0 0 L 5.366857528686523 5.366857528686523" fill="none" stroke="#ffffff" stroke-width="1" stroke-miterlimit="4" stroke-linecap="round" /></svg>';

    return Stack(
      children: <Widget>[
        Pinned.fromSize(
          bounds: Rect.fromLTWH(0.0, 0.0, 19.0, 19.0),
          size: Size(19.0, 19.0),
          pinLeft: true,
          pinRight: true,
          pinTop: true,
          pinBottom: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11.0),
              color: const Color(0xff6a6e70),
            ),
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(6.8, 6.9, 5.4, 5.4),
          size: Size(19.0, 19.0),
          fixedWidth: true,
          fixedHeight: true,
          child: SvgPicture.string(
            _svg_frf616,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
        Pinned.fromSize(
          bounds: Rect.fromLTWH(6.8, 6.9, 5.4, 5.4),
          size: Size(19.0, 19.0),
          fixedWidth: true,
          fixedHeight: true,
          child: SvgPicture.string(
            _svg_ld73re,
            allowDrawingOutsideViewBox: true,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  void delete(int pk, CardTitle newTitle) async {
    Navigator.pop(context);
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(message: "Please wait...");
    await pr.show();
    await titleBloc.deleteCard(pk);
    await testBloc.deleteQTestLists(pk);
    await titleBloc.updateFolderPercents(newTitle.pk);
    pr.hide();
    setState(() {});
  }

  showAlertDialog(BuildContext context, int index, CardTitle title) {
    Widget cancelButton = FlatButton(
      child: Text(
        "네",
        style: TextStyle(fontFamily: 'NotoSans', fontSize: 16),
      ),
      onPressed: () {
        delete(title.pk, newTitle);
      },
    );
    Widget continueButton = FlatButton(
      child: Container(
        alignment: Alignment.center,
        child:
            Text("아니요", style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
      ),
      onPressed: () => {
        Navigator.pop(context),
      },
    );

    // set up the AlertDialog
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      content: Builder(
        builder: (context) {
          // Get available height and width of the build area of this widget. Make a choice depending on the size.
          var height = MediaQuery.of(context).size.height;
          var width = MediaQuery.of(context).size.width;
          return Container(
            //height: height - 600,
            width: width - 100,
            alignment: Alignment.center,
            child: Text("삭제하시겠습니까?",
                style: TextStyle(
                    fontFamily: 'NotoSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
          );
        },
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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
                    height: height - 650,
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
                  child: Text("네"),
                  onPressed: () {
                    downloadCard(newTitle.pk);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("아니요"),
                  onPressed: () {
                    Navigator.pop(context, "아니요");
                  },
                ),
              ]);
        });
  }

  void showBackAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text("뒤로 가시겠습니까? \n",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSans',
                    fontSize: 20,
                  )),
              content: Text(
                  ""
                  "저장되지 않습니다.\n",
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
                    Navigator.pop(context);
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

  showUpdateAlertDialog(BuildContext context) async {
    await titleBloc.updateTitles(newTitle);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("뒤로 가시겠습니까?\n",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
              content: Text("앞으로 업데이트 알림을 보내지 않습니다.\n"),
              actions: <Widget>[
                FlatButton(
                  child: Text("아니요"),
                  onPressed: () {
                    Navigator.pop(context, "아니요");
                  },
                ),
                FlatButton(
                  child: Text("네"),
                  onPressed: () {
                    Navigator.pop(context);
                    setUpdate();
                  },
                )
              ]);
        });
  }

  void setUpdate() async {
    originTitle.getUpdate = 0;
    await titleBloc.updateTitles(originTitle);
    List<CardTitle> list = await getFolder(originTitle.pk);
    for (int i = 0; i < list.length; i++) {
      await titleBloc.updateFlag(list[i].pk, 0);
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return TodoListView();
      },
    ), (route) => false);
  }

  void downloadCard(int pk) async {
    TestBloc testBloc = TestBloc();
    await titleBloc.deleteFolders(newTitle.pk);
    newTitle = await getCard(pk);
    String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    newTitle.toggle = 1;
    newTitle.getUpdate = 1;
    newTitle.percentage = 0;
    newTitle.dbFolder = 1;
    newTitle.studyDate = date;
    newTitle.newFlag = 0;
    titleBloc.updateTitles(newTitle);
    List<CardTitle> list = await getFolder(newTitle.pk);
    List<TestList> quiz = List<TestList>();
    for (int i = 0; i < list.length; i++) {
      list[i].toggle = 1;
      list[i].getUpdate = 1;
      list[i].percentage = 0;
      list[i].dbFolder = 0;
      list[i].studyDate = date;
      quiz = await getQuiz(list[i].pk);
      await titleBloc.addTitles(list[i]);
      for (int j = 0; j < quiz.length; j++) {
        quiz[j].pk = list[i].pk;
        await testBloc.addTestLists(quiz[j]);
      }
    }
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
