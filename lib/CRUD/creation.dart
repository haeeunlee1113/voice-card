import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:voicequiz/CRUD/textDesign.dart';
import 'package:voicequiz/CRUD/Widget/title.dart';
import '../CRUD/Widget/TextInput.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/svg.dart';

class CreationView extends StatefulWidget {
  @override
  _CreationViewState createState() => _CreationViewState();
}

class _CreationViewState extends State<CreationView> {
  final controller = ScrollController();
  final tagController = new TextEditingController(text: "#");
  double offset = 0;
  String title = "";
  String description = "";
  bool textFlag = false;
  bool titleFlag = false;
  TestList newList;
  bool stateFlag = true;
  bool closeFlag = false;
  var random = Random();
  int length = 0;
  final find = ' ';
  final replaceWith = '#';
  int num = 0;

  FocusNode titleFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode tagFocus = FocusNode();
  List<FocusNode> questionFocus = List<FocusNode>();
  List<FocusNode> answerFocus = List<FocusNode>();
  List<TestList> testList = List<TestList>();
  CardTitle newTitle = CardTitle();

  final TestBloc testBloc = TestBloc();
  final TitleBloc titleBloc = TitleBloc();

  @override
  void initState() {
    super.initState();
    controller.addListener(onScroll);
    testList.add(TestList(question: "", answer: "", num: num++));
    questionFocus.add(FocusNode());
    answerFocus.add(FocusNode());
    tagController.addListener(() {
      if (tagController.text.isEmpty) {
        tagController.text = "#";
        tagController.selection = TextSelection.fromPosition(
          TextPosition(offset: tagController.text.length),
        );
      }
      if (tagController.text.contains(' ') | tagController.text.contains(',')) {
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
      } else if (tagController.text
          .contains(RegExp(r'[!@<>?"/:_`~;[\]\\|=+)(*&^%₩.-]'))) {
        length = tagController.text.length - 1;
        tagController.text = tagController.text.substring(0, length);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    testBloc.dispose();
    titleBloc.dispose();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (stateFlag && testList.length == 2) {
        setState(() {});
      }
    });
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
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
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Color(0xff5191c3),
                    onPressed: () {
                      showBackAlertDialog(context);
                    },
                  ),
                  Text("Make Card",
                      style: TextStyle(fontSize: 30.0, fontFamily: 'namsan')),
                  IconButton(
                      icon: Icon(Icons.file_download),
                      color: Color(0xff5191c3),
                      iconSize: 29,
                      onPressed: () {
                        showSaveAlertDialog(context);
                      }),
                ],
              ),
            ),

            Container(
              height: 15.0,
            ),
            TitleText(
              title: "Title",
              onChange: (val) => setState(() {
                title = val;
                title = title.trimLeft();
                title.isNotEmpty ? titleFlag = true : null;
              }),
              currentFocus: titleFocus,
              nextFocus: descriptionFocus,
              initial: title,
              config: config(titleFocus, context),
              autofocus: true,
            ),
            Container(
              height: 20.0,
            ),
            //SizedBox(height: 20),
            titleFlag
                ? TitleText(
                    title: "Description",
                    onChange: (val) => setState(() {
                      description = val;
                    }),
                    currentFocus: descriptionFocus,
                    nextFocus: tagFocus,
                    initial: description,
                    config: config(descriptionFocus, context),
                    autofocus: true,
                  )
                : SizedBox(),
            SizedBox(height: 20),
            titleFlag ? hashTag() : SizedBox(),
            SizedBox(height: 20),
            titleFlag
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: testList.length,
                    itemBuilder: (BuildContext context, int index) {
                      addTestList();
                      return Container(
                        key: ValueKey(testList[index].num),
                        padding: EdgeInsets.only(bottom: 10),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  width: MediaQuery.of(context).size.width - 20,
                                  //height: MediaQuery.of(context).size.height * 0.2,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/makecardwhite@3x.png'),
                                      fit: BoxFit.fill,
                                    ),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 40,
                                        width:
                                            MediaQuery.of(context).size.width -
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
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              "Q.",
                                              style: TitleTextStyle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: TextInputWidget(
                                              color: Colors.grey[400],
                                              onChange: (val) {
                                                setState(() {
                                                  testList[index].question =
                                                      val;
                                                });
                                              },
                                              currentFocus:
                                                  questionFocus[index],
                                              nextFocus: answerFocus[index],
                                              initial: testList[index].question,
                                              config: config(
                                                questionFocus[index],
                                                context,
                                              ),
                                              autofocus: true,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: Text(
                                              "A.",
                                              style: TitleTextStyle,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: TextInputWidget(
                                              color: Colors.grey[400],
                                              onChange: (val) => setState(() {
                                                testList[index].answer = val;
                                              }),
                                              currentFocus: answerFocus[index],
                                              nextFocus:
                                                  (index + 1 != testList.length)
                                                      ? questionFocus[index + 1]
                                                      : null,
                                              initial: testList[index].answer,
                                              config: config(
                                                  answerFocus[index], context),
                                              autofocus: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 1,
                                  top: -10,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (testList.length > 1) {
                                          closeFlag = true;
                                          testList.removeAt(index);
                                        }
                                      });
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: 25,
                                      height: 25,
                                      padding: EdgeInsets.all(4),
                                      child: _deleteButton(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    })
                : Container(),
          ],
        ),
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

  Widget hashTag() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      width: MediaQuery.of(context).size.width - 20,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/makecardwhite@3x.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 40,
            width: MediaQuery.of(context).size.width - 20,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/makecardgrey@3x.png'),
                fit: BoxFit.fill,
              ),
            ),
            alignment: Alignment(0.0, 0.0),
            child: Container(
              child: Text(
                "HashTags",
                style: TitleTextStyle,
              ),
            ),
          ),
          SizedBox(height: 7),
          Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height * 0.07,
              child: KeyboardActions(
                disableScroll: true,
                config: config(tagFocus, context),
                child: TextFormField(
                  controller: tagController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.go,
                  focusNode: tagFocus,
                  onFieldSubmitted: (term) {
                    tagFocus.unfocus();
                    FocusScope.of(context).requestFocus(questionFocus[0]);
                  },
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.deny(
                  //       RegExp(r'[!@<>?"/:_`~;[\]\\|=+)(*&^%₩,.-]')),
                  // ],
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(7),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void addTestList() {
    int num = testList.length;
    if (!closeFlag) {
      if (testList.length > 0) {
        if (testList.elementAt(num - 1).question.isNotEmpty) {
          testList.add(TestList(question: "", answer: "", num: num++));
          questionFocus.add(FocusNode());
          answerFocus.add(FocusNode());
        }
      }
    }
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

  void saveCard() async {
    bool saveFlag = false;
    length = tagController.text.length - 1;
    newTitle.tag = tagController.text;
    if (newTitle.tag[length] == "#") {
      newTitle.tag = newTitle.tag.substring(0, length);
    }
    newTitle.tag = newTitle.tag.replaceAll(replaceWith, find);
    if (length == 0) newTitle.tag = "";
    if (title.isEmpty || description.isEmpty || newTitle.tag.isEmpty) {
      saveFlag = false;
    } else {
      newTitle.title = title;
      newTitle.description = description;
      if (testList.length > 0) {
        for (int i = 0; i < testList.length - 1; i++) {
          newList = testList.elementAt(i);
          testBloc.addTestLists(newList);
          if (newList.question.isEmpty) {
            saveFlag = false;
            //testBloc.deleteTestLists(newList.num);
            break;
          }
          if (newList.answer.isEmpty) {
            saveFlag = false;
            //testBloc.deleteTestLists(newList.num);
            break;
          }
          saveFlag = true;
        }
        newList = testList.elementAt(testList.length - 1);
        //newList.pk = newTitle.pk;
        if (newList.question.isNotEmpty && newList.answer.isNotEmpty) {
          saveFlag = true;
        }
      }
    }
    if (saveFlag) {
      await uploadNewData(newTitle, testList);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (context) {
          return TodoListView();
        },
      ), (route) => false);
    } else {
      //testBloc.deleteQTestLists(newTitle.pk);
      showBlankAlertDialog(context);
    }
  }

  void showBackAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              title: Text("뒤로가시겠습니까? \n",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'NotoSans',
                    fontSize: 18,
                  )),
              content: Text("작성 중이던 내용이 사라집니다.\n",
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
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                      builder: (context) {
                        return TodoListView();
                      },
                    ), (route) => false);
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
                    //height: height - 600,
                    width: width - 100,
                    alignment: Alignment.center,
                    child: Text("저장하시겠습니까?",
                        style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
                  );
                },
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("네",
                      style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context);
                    saveCard();
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

  config(FocusNode focus, BuildContext context) {
    return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        actions: [
          KeyboardActionsItem(
              displayArrows: false,
              focusNode: focus,
              toolbarButtons: [
                (node) {
                  return GestureDetector(
                      onTap: () => node.unfocus(),
                      child: Container(
                          color: Colors.grey[200],
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "CLOSE",
                            style: TextStyle(color: Colors.black),
                          )));
                }
              ])
        ]);
  }
}
