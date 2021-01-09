import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

//3887C3
const iconColor = Color(0xFF3887C3);

class MicAnimation extends StatefulWidget {
  @override
  _MicAnimationState createState() => _MicAnimationState();
}

class _MicAnimationState extends State<MicAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    if (mounted) {
      super.initState();
      _animationController =
          AnimationController(vsync: this, duration: Duration(seconds: 1));
      _animationController.repeat(reverse: true);
      _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
        ..addListener(() {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Icon(Icons.mic, color: iconColor, size: 40.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 240, 240, 245),
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(60, 56, 135, 195),
                  blurRadius: _animation.value,
                  spreadRadius: _animation.value)
            ]),
      ),
    );
  }
}

class SpeakerAnimation extends StatefulWidget {
  @override
  _SpeakerAnimationState createState() => _SpeakerAnimationState();
}

class _SpeakerAnimationState extends State<SpeakerAnimation> {
  int idx = 0;
  Timer timer;
  List<Icon> volume = [
    Icon(FeatherIcons.volume, color: iconColor, size: 40.0),
    Icon(FeatherIcons.volume1, color: iconColor, size: 40.0),
    Icon(FeatherIcons.volume2, color: iconColor, size: 40.0),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 300), (t) {
      if (this.mounted) {
        setState(() {
          idx = (idx + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // timer가 null이면 null을 반환하고, 아니면 cancel() 호출
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: volume[idx],
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 240, 240, 245),
        ),
      ),
    );
  }
}

class SimpleSpeakerAnimation extends StatefulWidget {
  @override
  _SimpleSpeakerAnimationState createState() => _SimpleSpeakerAnimationState();
}

class _SimpleSpeakerAnimationState extends State<SimpleSpeakerAnimation> {
  int idx = 0;
  Timer timer;
  List<Icon> volume = [
    Icon(FeatherIcons.volume, color: iconColor, size: 40.0),
    Icon(FeatherIcons.volume1, color: iconColor, size: 40.0),
    Icon(FeatherIcons.volume2, color: iconColor, size: 40.0),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 300), (t) {
      if (this.mounted) {
        setState(() {
          idx = (idx + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel(); // timer가 null이면 null을 반환하고, 아니면 cancel() 호출
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.1,
        height: MediaQuery.of(context).size.width * 0.1,
        child: volume[idx],
        /*decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 240, 240, 245),
        ),*/
      ),
    );
  }
}
