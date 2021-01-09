import 'package:flutter/material.dart';
import 'package:voicequiz/CRUD/textDesign.dart';
import 'package:voicequiz/CRUD/Widget/TextInput.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class TitleText extends StatefulWidget {
  final String initial;
  final String title;
  final Function(String) onChange;
  final FocusNode currentFocus;
  final FocusNode nextFocus;
  final KeyboardActionsConfig config;
  final bool autofocus;
  const TitleText(
      {Key key,
      this.title,
      this.onChange,
      this.currentFocus,
      this.nextFocus,
      this.initial,
      this.config,
      this.autofocus})
      : super(key: key);

  @override
  _TitleTextState createState() => _TitleTextState();
}

class _TitleTextState extends State<TitleText> {
  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.center,
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
                  widget.title,
                  style: TitleTextStyle,
                ),
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.07,
            alignment: Alignment.centerLeft,
            child: TextInputWidget(
              currentFocus: widget.currentFocus,
              nextFocus: widget.nextFocus,
              initial: widget.initial,
              onChange: widget.onChange,
              config: widget.config,
              autofocus: widget.autofocus,
            ),
          ),
        ],
      ),
    );
  }
}
