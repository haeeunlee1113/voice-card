import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voicequiz/top/QuizCard.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:voicequiz/DB/login.dart';
import 'dart:async';
import 'package:adobe_xd/pinned.dart';
import 'package:flutter_svg/svg.dart';
import 'package:adobe_xd/blend_mask.dart';

class SearchList extends StatefulWidget {
  SearchList({Key key, @required this.trigger}) : super(key: key);
  final bool trigger;
  @override
  State<StatefulWidget> createState() => _SearchState();
}

class _SearchState extends State<SearchList> {
  CardTitle quiz;
  bool trigger = false;
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  String _error;
  List<CardTitle> _results = List<CardTitle>();
  List<CardTitle> quizs = List<CardTitle>();
  Timer debounceTimer;
  bool searchFlag = false;

  void performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _error = null;
        _results = quizs;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
      _results = List();
    });

    final repos = await search(query);

    if (this._searchQuery.text == query && this.mounted) {
      setState(() {
        _isSearching = false;
        if (repos != null) {
          _results = repos;
        } else {
          _error = 'Error searching repos';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background@3x.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
            padding: EdgeInsets.only(
              top: 40.0,
            ),
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            child: Column(children: <Widget>[
              Container(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    color: Color(0xff5191c3),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                        builder: (context) {
                          return TodoListView();
                        },
                      ), (route) => false);
                    },
                  ),
                  Stack(
                    children: <Widget>[
                      Positioned(
                          child: Container(
                              width: MediaQuery.of(context).size.width - 48,
                              child: Stack(
                                children: <Widget>[
                                  Hero(
                                    tag: 'imageHero',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                          height: 45,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              48,
                                          padding: EdgeInsets.only(
                                              left: 10.0, top: .0, right: 10.0),
                                          child: Stack(children: <Widget>[
                                            _searchBar(),
                                            Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    80,
                                                height: 43,
                                                padding:
                                                    EdgeInsets.only(left: 25),
                                                child: Center(
                                                  child: TextFormField(
                                                    autofocus: true,
                                                    controller: _searchQuery,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    onFieldSubmitted: (term) {
                                                      setState(() {
                                                        performSearch(
                                                            _searchQuery.text);
                                                      });
                                                    },
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                    ),
                                                  ),
                                                )),
                                          ])),
                                    ),
                                  ),
                                  Positioned(
                                      right: 15.0,
                                      top: 0.91,
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          width: 41,
                                          height: 41,
                                          padding: EdgeInsets.all(2.5),
                                          child: Container(
                                            child: MaterialButton(
                                              padding: EdgeInsets.only(
                                                  top: 2.9, left: 2.9),
                                              child: CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.white,
                                                  child: CircleAvatar(
                                                    radius: 13.5,
                                                    backgroundImage: AssetImage(
                                                        'assets/images/Subtraction 5@3x.png'),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    child: Container(
                                                      child: Icon(
                                                        Icons.search,
                                                        size: 22,
                                                        color: Colors.white,
                                                      ),
                                                      padding: EdgeInsets.only(
                                                        left: 2.3,
                                                        top: 1.5,
                                                      ),
                                                    ),
                                                  )),
                                              shape: CircleBorder(),
                                              onPressed: () {
                                                setState(() {
                                                  performSearch(
                                                      _searchQuery.text);
                                                });
                                              },
                                            ),
                                          ))),
                                ],
                              ))),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: buildBody(context),
              )
            ])),
      ),
    );
  }

  _searchBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          begin: Alignment(0.0, -1.0),
          end: Alignment(0.0, 1.0),
          colors: [const Color(0x66b3d4ee), const Color(0x663787c3)],
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
    );
  }

  Widget buildBody(BuildContext context) {
    if (_isSearching) {
      return Container();
    } else if (_searchQuery.text.isEmpty) {
      return Container(
          padding: EdgeInsets.only(top: 80.0),
          child: Text('검색 결과가 없습니다.',
              style: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 23,
              ))); //뭘띄워야할지 잘 모르겠당

    } else {
      return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 8.0),
          itemCount: _results.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                child: Column(
              children: <Widget>[
                NormalQuizView(
                  title: _results[index],
                  search: true,
                  searchFolder: false,
                  update: false,
                  longPress: false,
                ),
                checkIndex(index, _results.length)
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
            ));
          });
    }
  }
}

class CenterTitle extends StatelessWidget {
  final String title;

  CenterTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        alignment: Alignment.center,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline,
          textAlign: TextAlign.center,
        ));
  }
}
