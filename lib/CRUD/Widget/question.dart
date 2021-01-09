import 'package:flutter/material.dart';
import 'package:voicequiz/CRUD/Widget/TextInput.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/CRUD/textDesign.dart';

class test extends StatefulWidget {
  final int num;
  final List<TestList> testList;

  const test({Key key, this.testList, this.num}) : super(key: key);
  @override
  _testState createState() => _testState();
}

class _testState extends State<test> {
  String index;
  FocusNode questionFocus = FocusNode();
  FocusNode answerFocus = FocusNode();
  int pos;

  @override
  void initState() {
    super.initState();
    pos = widget.testList.indexWhere((element) => element.num == widget.num);
    index = (pos + 1).toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            index,
            style: TitleTextStyle,
          ),
          SizedBox(height: 5),
          Row(
            children: <Widget>[
              Text(
                "Q",
                style: TitleTextStyle,
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextInputWidget(
                  color: Colors.grey[400],
                  onChange: (val) {
                    setState(() {
                      widget.testList.elementAt(pos).question = val;
                    });
                  },
                  currentFocus: questionFocus,
                  nextFocus: answerFocus,
                  initial: widget.testList.elementAt(pos).question,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                "A",
                style: TitleTextStyle,
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextInputWidget(
                    color: Colors.grey[400],
                    onChange: (val) {
                      setState(() {
                        widget.testList.elementAt(pos).answer = val;
                      });
                    },
                    currentFocus: answerFocus,
                    initial: widget.testList.elementAt(pos).answer),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MakeList extends StatefulWidget {
  final List<TestList> testList;
  MakeList({Key key, this.testList}) : super(key: key);
  @override
  _MakeListState createState() => _MakeListState();
}

class _MakeListState extends State<MakeList> {
  int index;
  int num;
  List<Widget> widgets = List<Widget>();
  bool closeFlag = false;

  @override
  void initState() {
    super.initState();
    index = widget.testList.length;
  }

  @override
  Widget build(BuildContext context) {
    addTestList();
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.testList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: <Widget>[
                Stack(
                  overflow: Overflow.visible,
                  children: <Widget>[
                    test(num: index, testList: widget.testList),
                    Positioned(
                      child: IconButton(
                        icon: Icon(Icons.close),
                        alignment: Alignment.centerRight,
                        color: Colors.black,
                        onPressed: () {
                          setState(() {
                            if (widget.testList.length > 1) {
                              closeFlag = true;
                              widget.testList.removeAt(index);
                            }
                          });
                        },
                      ),
                      right: -5,
                      top: -22,
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          );
        });
  }

  void addTestList() {
    if (index == 0) {
      widget.testList.add(TestList(question: "", answer: "", num: index));
      index++;
    }
    print("잘 작동된다");
    num = widget.testList.length;
    if (!closeFlag) {
      if (widget.testList.length > 0) {
        if (widget.testList.elementAt(num - 1).question.isNotEmpty) {
          widget.testList.add(TestList(question: "", answer: "", num: index));
          index++;
        }
      }
    }
  }
}
