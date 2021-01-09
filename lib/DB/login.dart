import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:voicequiz/DB/titleDB.dart';

String getAppId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-6425761718131036~2944836386';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-6425761718131036~6900586782';
  } else
    return null;
}

String getBannerAdInitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  } else
    return null;
}

String getVideoAdInitID() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/5135589807';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/8691691433';
  } else
    return null;
}

InterstitialAd getAd() {
  return InterstitialAd(
    adUnitId: getVideoAdInitID(),
  );
}

final String loginName = 'login';

class UserInfo {
  int pk;
  String date;
  int top;
  int study;

  UserInfo({this.pk, this.date, this.top, this.study});

  factory UserInfo.fromJson(Map<String, dynamic> json) => new UserInfo(
        pk: json["pk"],
        date: json["date"],
        top: json["top"],
        study: json["study"]
      );

  Map<String, dynamic> toJson() => {
        "pk": pk,
        "date": date,
        "top" : top,
        "study" : study
      };
}

String date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

class LoginDBHelper {
  LoginDBHelper._();

  static final LoginDBHelper _db = LoginDBHelper._();

  factory LoginDBHelper() => _db;
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await testInitDB();
    return _database;
  }

  testInitDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'Login.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $loginName (
            pk INTEGER,
            date TEXT,
            top INTEGER,
            study INTEGER)
          ''');
      },
    );
  }

  updateDate() async {
    final db = await database;
    //await db.rawUpdate("UPDATE $loginName SET date = ? WHERE pk = 1", [date]);
    await db.rawUpdate("UPDATE $loginName SET date = ? WHERE pk = 1", [date]);
  }

  createDate() async {
    final db = await database;
    UserInfo userInfo = UserInfo(pk: 1, date: date, top : 0, study: 0);
    var res = await db.insert(loginName, userInfo.toJson());
    return res;
  }

  deleteDate() async {
    final db = await database;
    var res = await db.rawDelete('DELETE FROM $loginName');
  }

  Future<UserInfo> getDate() async {
    final db = await database;
    var res = await db.query(loginName, where: 'pk=1');
    return res.isEmpty ? Null : UserInfo.fromJson(res.first);
  }

  updateTop() async{
    final db = await database;
    await db.rawUpdate("UPDATE $loginName SET top = 1 WHERE pk = 1");
  }

  updateStudy() async{
    final db = await database;
    await db.rawUpdate("UPDATE $loginName SET study = 1 WHERE pk = 1");
  }

  loginDB() async {
    //LoginDBHelper().deleteDate();
    final db = await database;
    var res = await db.query(loginName, where: 'pk=1');
    if (res.isEmpty) {
      await LoginDBHelper().createDate();
    } else {
      UserInfo userInfo = UserInfo.fromJson(res.first);
      print("여기");
      DateTime dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(userInfo.date);
      await decPercentage(dateTime);
      await LoginDBHelper().updateDate();
    }
  }
}

decPercentage(DateTime oldDate) async {
  TitleBloc titleBloc = TitleBloc();
  List<CardTitle> list = List<CardTitle>();
  DateTime newTime = DateTime.now();
  print(oldDate);
  print(newTime);
  int result = newTime.difference(oldDate).inDays;
  print(result);
  if (result != 0) {
    result *= result + 1;
    result = (result / 2).round();
    print(result);
    list = await DBHelper().getInFolder();
    for (int i = 0; i < list.length; i++) {
      list[i].percentage -= result;
      if (list[i].percentage < 0) list[i].percentage = 0;
      await titleBloc.updatePercent(list[i].pk, list[i].percentage);
    }
    list = await DBHelper().getAllCardTitle();
    for (int i = 0; i < list.length; i++) {
      if (list[i].dbFolder == 1) {
        await titleBloc.updateFolderPercents(list[i].pk);
      } else {
        list[i].percentage -= result;
        if (list[i].percentage < 0) list[i].percentage = 0;
        await titleBloc.updatePercent(list[i].pk, list[i].percentage);
      }
    }
  }
}
