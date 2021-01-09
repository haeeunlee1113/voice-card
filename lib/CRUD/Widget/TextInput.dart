import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class TextInputWidget extends StatefulWidget {
  final Function(String) onChange;
  final String initial;
  final Color color;
  final FocusNode currentFocus;
  final FocusNode nextFocus;
  final KeyboardActionsConfig config;
  final bool autofocus;
  const TextInputWidget(
      {Key key,
      this.onChange,
      this.color,
      this.currentFocus,
      this.nextFocus,
      this.initial,
      this.config,
      this.autofocus})
      : super(key: key);
  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInputWidget> {
  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      disableScroll: true,
      config: widget.config,
      child: TextFormField(
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.deny(
              RegExp(r'[!@<>?"/:_`~;[\]\\|=+)(*&^%₩.-]'))
        ],
        autofocus: widget.autofocus,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.go,
        focusNode: widget.currentFocus,
        initialValue: widget.initial,
        onFieldSubmitted: (term) {
          widget.currentFocus.unfocus();
          FocusScope.of(context).requestFocus(widget.nextFocus);
        },
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(7),
        ),
        onChanged: widget.onChange,
      ),
    );
  }
}
