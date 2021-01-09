import 'package:flutter/material.dart';

TextStyle baseTextStyle() {
  return TextStyle(fontFamily: 'NotoSans');
}

TextStyle headerTextStyle() {
  return baseTextStyle().copyWith(
    color: Colors.black,
    fontSize: 25.0,

  );
}

TextStyle regularTextStyle() {
  return baseTextStyle().copyWith(
    color: Colors.black,
    fontSize: 20.0,
    fontWeight: FontWeight.w300,
  );
}

TextStyle subHeaderTextStyle() {
  return regularTextStyle().copyWith(fontSize: 12.0);
}