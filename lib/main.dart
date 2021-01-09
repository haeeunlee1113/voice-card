import 'package:flutter/material.dart';
import 'package:voicequiz/top/ShowTopList.dart';
import 'package:voicequiz/DB/login.dart';
import 'package:voicequiz/DB/server.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:voicequiz/top/ShowTutorial.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  loginServer();
  Admob.initialize(getAppId());
  await LoginDBHelper().loginDB();
  UserInfo user = await LoginDBHelper().getDate();
  FirebaseAdMob.instance.initialize(appId: getAppId());
  permission();
  print("로그인");
  runApp(MyApp(top: user.top));
}

class MyApp extends StatelessWidget {
  final int top;
  const MyApp({Key key, this.top});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'voice flashCard Demo',
      home: top == 0
          ? TutorialView(
              pageNum: 1,
            )
          : TodoListView(),
    );
  }
}

void permission() async {
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler()
      .requestPermissions([PermissionGroup.microphone, PermissionGroup.speech]);
  //print('per1 : $permissions');
}
