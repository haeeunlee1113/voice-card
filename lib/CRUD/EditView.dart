import 'package:flutter/material.dart';
import 'package:voicequiz/CRUD/Widget/TextInput.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/CRUD/textDesign.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:voicequiz/CRUD/Widget/title.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:flutter/cupertino.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/svg.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class EditView extends StatefulWidget {
  final int num;
  final CardTitle newTitle;
  final CardTitle folderTitle;
  const EditView({Key key, this.num, this.newTitle, this.folderTitle})
      : super(key: key);
  @override
  _EditViewState createState() => _EditViewState();
}

class _EditViewState extends State<EditView> {
  ScrollController controller = ScrollController();
  QTestBloc qtestBloc;
  FocusNode titleFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode tagFocus = FocusNode();
  List<FocusNode> questionFocus = List<FocusNode>();
  List<FocusNode> answerFocus = List<FocusNode>();
  TitleBloc titleBloc = TitleBloc();
  TestBloc testBloc = TestBloc();
  int index = 0;
  bool addFlag = false;
  CardTitle newTitle = CardTitle();
  List<TestList> editList = List<TestList>();
  List<int> deletedTest = List<int>();
  List<int> addTest = List<int>();
  bool originFlag = true;
  bool closeFlag = false;
  bool stateFlag = true;
  int num = 0;
  TestList newList = TestList(question: "");
  TextEditingController tagController;
  int length = 0;
  final find = ' ';
  final replaceWith = '#';

  @override
  void initState() {
    super.initState();
    qtestBloc = QTestBloc(widget.num);
    questionFocus.add(FocusNode());
    answerFocus.add(FocusNode());
    newTitle = widget.newTitle;
    newTitle.tag = newTitle.tag + "#";
    tagController = new TextEditingController(text: newTitle.tag);
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
  }

  @override
  void dispose() {
    qtestBloc.dispose();
    titleBloc.dispose();
    testBloc.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (stateFlag)
        setState(() {
          if (editList.length > 0) stateFlag = false;
        });
    });

    return Scaffold(
      body: SingleChildScrollView(
        //controller: controller,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 70.0,
              alignment: Alignment(0.0, 1.0),
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
                  Text("Edit Card",
                      style: TextStyle(fontFamily: 'namsan', fontSize: 30.0)),
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
            SizedBox(
              height: 15,
            ),
            TitleText(
              title: "Title",
              onChange: (val) => setState(() {
                newTitle.title = val;
              }),
              currentFocus: titleFocus,
              nextFocus: descriptionFocus,
              initial: newTitle.title,
              config: config(titleFocus, context),
              autofocus: false,
            ),
            SizedBox(height: 20),
            TitleText(
              title: "Description",
              onChange: (val) => setState(() {
                newTitle.description = val;
              }),
              currentFocus: descriptionFocus,
              nextFocus: tagFocus,
              initial: newTitle.description,
              config: config(descriptionFocus, context),
              autofocus: false,
            ),
            SizedBox(height: 20),
            hashTag(),
            SizedBox(height: 20),
            originFlag ? inputEditList(newTitle.pk) : Container(),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: editList.length,
              itemBuilder: (BuildContext context, int index) {
                if (!closeFlag) addTestList(newTitle.pk);
                return Container(
                  key: ValueKey(editList[index].num),
                  padding: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: <Widget>[
                      Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            width: MediaQuery.of(context).size.width - 20,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/makecardwhite@3x.png'),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 40,
                                  width: MediaQuery.of(context).size.width - 20,
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
                                      child: TextInputWidget(
                                        color: Colors.grey[400],
                                        onChange: (val) {
                                          setState(() {
                                            editList[index].question = val;
                                          });
                                        },
                                        currentFocus: questionFocus[index],
                                        nextFocus: answerFocus[index],
                                        initial: editList[index].question,
                                        config: config(
                                            questionFocus[index], context),
                                        autofocus: false,
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
                                      padding: EdgeInsets.only(left: 10.0),
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
                                          editList[index].answer = val;
                                        }),
                                        currentFocus: answerFocus[index],
                                        nextFocus:
                                            (index + 1 != editList.length)
                                                ? questionFocus[index + 1]
                                                : null,
                                        initial: editList[index].answer,
                                        config:
                                            config(answerFocus[index], context),
                                        autofocus: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          //TextInput(color: Colors.grey[400], initial: editList[index].question, onChange: (val) => setState((){editList[index].question = val;})),

                          Positioned(
                            right: 1,
                            top: -10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (editList.length > 1) {
                                    closeFlag = true;
                                    deletedTest.add(editList[index].num);
                                    addTest.removeWhere((element) =>
                                        element == editList[index].num);
                                    editList.removeAt(index);
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
                      SizedBox(height: 20),
                    ],
                  ),
                );
              },
            )
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

  inputEditList(int pk) {
    return StreamBuilder(
        stream: qtestBloc.testLists,
        builder:
            (BuildContext context, AsyncSnapshot<List<TestList>> snapshot) {
          if (snapshot.hasData) {
            if (originFlag) {
              editList.addAll(snapshot.data);
              print(editList.length);
              num = (editList[editList.length - 1].num) + 1;
              editList
                  .add(TestList(question: "", answer: "", num: num++, pk: pk));
              for (int i = 0; i < editList.length; i++) {
                questionFocus.add(FocusNode());
                answerFocus.add(FocusNode());
              }
              addTest.add(num - 1);
              questionFocus.add(FocusNode());
              answerFocus.add(FocusNode());
              originFlag = false;
            }
            return Container();
          } else
            return Center(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            );
        });
  }

  addTestList(int pk) {
    int listLength = editList.length;
    if (listLength > 0) {
      if (editList.elementAt(listLength - 1).question.isNotEmpty) {
        editList.add(TestList(question: "", answer: "", num: num++, pk: pk));
        addTest.add(num - 1);
        questionFocus.add(FocusNode());
        answerFocus.add(FocusNode());

        addFlag = true;
      }
    }
  }

  void saveCard() async {
    bool saveFlag = false;
    int i;
    TestList newList = TestList();
    int id;
    int editLength = editList.length;
    length = tagController.text.length - 1;
    newTitle.tag = tagController.text;
    if (newTitle.tag[length] == "#") {
      newTitle.tag = newTitle.tag.substring(0, length);
    }
    newTitle.tag = newTitle.tag.replaceAll(replaceWith, find);
    if (length == 0) newTitle.tag = "";

    if (editLength > 0) {
      if (newTitle.title.isEmpty ||
          newTitle.description.isEmpty ||
          newTitle.tag.isEmpty) {
        saveFlag = false;
      } else {
        if (editLength == 1) {
          if (editList[0].question.isEmpty)
            saveFlag = false;
          else if (editList[0].answer.isEmpty)
            saveFlag = false;
          else
            saveFlag = true;
        } else {
          for (i = 0; i < editLength - 1; i++) {
            newList = editList.elementAt(i);
            if (newList.question.isEmpty) {
              saveFlag = false;
              break;
            } else if (newList.answer.isEmpty) {
              saveFlag = false;
              break;
            }
            saveFlag = true;
          }
        }
      }
    }
    if (saveFlag) {
      await testBloc.deleteQTestLists(newTitle.pk);
      for (i = 0; i < editLength - 1; i++) {
        await testBloc.addTestLists(editList[i]);
      }
      if (editList[editLength - 1].question.isNotEmpty &&
          editList[editLength - 1].answer.isNotEmpty) {
        await testBloc.addTestLists(editList[i]);
      } else
        editList.removeLast();
      await updateData(newTitle, editList);
      newTitle.id != 0
          ? Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return QuizListView(
                  id: newTitle.id,
                  title: widget.folderTitle,
                  search: false,
                  userName: newTitle.userName,
                  update: true,
                );
              },
            ), (route) => false)
          : Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
              builder: (context) {
                return TodoListView();
              },
            ), (route) => false);
    } else
      showBlankAlertDialog(context);
  }

  void showBlankAlertDialog(BuildContext context) async {
    String result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text("채워지지 않은 항목이 있습니다",
                style: TextStyle(fontFamily: 'NotoSans')),
            actions: <Widget>[
              FlatButton(
                child: Text("닫기", style: TextStyle(fontFamily: 'NotoSans')),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
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
                      fontFamily: 'NotoSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              content: Text(""
                  "저장되지 않습니다.\n"),
              actions: <Widget>[
                FlatButton(
                  child: Text("네",
                      style: TextStyle(fontFamily: 'NotoSans', fontSize: 16)),
                  onPressed: () {
                    Navigator.pop(context);
                    newTitle.id != 0
                        ? Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(
                            builder: (context) {
                              return QuizListView(
                                id: newTitle.id,
                                title: widget.folderTitle,
                                search: false,
                                userName: newTitle.userName,
                                update: true,
                              );
                            },
                          ), (route) => false)
                        : Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(
                            builder: (context) {
                              return TodoListView();
                            },
                          ), (route) => false);
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

  void showSaveAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
              content: Builder(
                builder: (context) {
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
          KeyboardActionsItem(focusNode: focus, toolbarButtons: [
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
