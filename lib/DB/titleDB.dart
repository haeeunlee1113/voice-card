import 'dart:async';
import 'dart:io';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'package:voicequiz/DB/server.dart';

final String titleName = 'CArdTITLE';

class CardTitle {
  String title;
  String description;
  int id;
  int pk;
  int likes;
  String userName;
  String date;
  int toggle;
  int getUpdate;
  int percentage;
  bool folder;
  int dbFolder;
  String studyDate;
  String tag;
  int count;
  int newFlag;

  CardTitle(
      {this.title,
      this.description,
      this.id,
      this.pk,
      this.likes,
      this.userName,
      this.date,
      this.toggle,
      this.getUpdate,
      this.percentage,
      this.folder,
      this.studyDate,
      this.dbFolder,
      this.count,
      this.tag,
      this.newFlag});

  factory CardTitle.fromJson(Map<String, dynamic> json) => new CardTitle(
      title: json["title"],
      description: json["description"],
      id: json["card_pk"],
      pk: json["pk"],
      likes: json["likes"],
      userName: json["username"],
      date: json["create_date"],
      toggle: json["toggle"],
      getUpdate: json["getUpdate"],
      percentage: json["percentage"],
      dbFolder: json["folder"],
      studyDate: json["studyDate"],
      tag: json["tag"],
      count: json["count"],
      newFlag: json["newFlag"]);
  factory CardTitle.fromServerJson(Map<String, dynamic> json) => new CardTitle(
        title: json["title"],
        description: json["description"],
        id: json["card_pk"],
        pk: json["pk"],
        likes: json["likes"],
        userName: json["username"],
        date: json["create_date"],
        folder: json["folder"],
        count: json["count"],
        tag: json["tag"],
      );

  factory CardTitle.fromSearchJson(Map<String, dynamic> json) => new CardTitle(
        title: json["title"],
        description: json["description"],
        pk: json["id"],
        likes: json["likes"],
        folder: json["folder"],
        tag: json["tag"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "card_pk": id,
        "pk": pk,
        "likes": likes,
        "username": userName,
        "create_date": date,
        "toggle": toggle,
        "getUpdate": getUpdate,
        "percentage": percentage,
        "folder": dbFolder,
        "studyDate": studyDate,
        "tag": tag,
        "count": count,
        "newFlag": newFlag,
      };

  Map<String, dynamic> titleToMap() => {
        "username": userName,
        "pk": pk,
        "title": title,
        "description": description,
        "tag": tag,
      };
}

class DBHelper {
  DBHelper._();

  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'CArdTITLEDB.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $titleName (
            card_pk INTEGER,
            pk INTEGER,
            title TEXT,
            description TEXT,
            likes INTEGER,
            username TEXT,
            create_date TEXT,
            toggle INTEGER,
            getUpdate INTEGER,
            percentage INTEGER,
            folder INTEGER,
            studyDate TEXT,
            tag TEXT,
            count INTEGER,
            newFlag INTEGER)
          ''');
      },
    );
  }

  createData(CardTitle cardtitle) async {
    final db = await database;
    print("뭐가 문제니");
    await db.insert(titleName, cardtitle.toJson());
  }

  Future<CardTitle> getCardTitle(int id) async {
    final db = await database;
    var res = await db.query(titleName, where: 'pk=?', whereArgs: [id]);
    return res.isNotEmpty ? CardTitle.fromJson(res.first) : Null;
  }

  Future<List<CardTitle>> getQCardTitle(int id) async {
    final db = await database;
    var res =
        await db.rawQuery('SELECT * FROM $titleName WHERE card_pk=?', [id]);
    return res.isNotEmpty ? res.map((c) => CardTitle.fromJson(c)).toList() : [];
  }

  Future<List<CardTitle>> getAllCardTitle() async {
    final db = await database;
    var res = await db.rawQuery(
        'SELECT * FROM $titleName WHERE card_pk=0 ORDER BY datetime(studyDate) DESC');

    List<CardTitle> list =
        res.isNotEmpty ? res.map((c) => CardTitle.fromJson(c)).toList() : [];
    return list;
  }

  Future<List<CardTitle>> getInFolder() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM $titleName WHERE card_pk != 0");
    List<CardTitle> list =
        res.isNotEmpty ? res.map((c) => CardTitle.fromJson(c)).toList() : [];
    return list;
  }

  updateCardTitle(CardTitle cardtitle) async {
    final db = await database;
    var res, es;
    res = await db.query(titleName, where: 'pk=?', whereArgs: [cardtitle.pk]);
    if (res.isEmpty) {
      await db.insert(titleName, cardtitle.toJson());
    } else {
      es = await db.update(titleName, cardtitle.toJson(),
          where: 'pk=?', whereArgs: [cardtitle.pk]);
    }
    return es;
  }

  deleteCardTitle(int id) async {
    final db = await database;
    await db.delete(titleName, where: 'pk=?', whereArgs: [id]);
  }

  deleteFolder(int id) async {
    TestBloc testBloc = TestBloc();
    final db = await database;
    List<CardTitle> list = await DBHelper().getQCardTitle(id);
    for (int i = 0; i < list.length; i++)
      await testBloc.deleteQTestLists(list[i].pk);
    await db.delete(titleName, where: 'pk=?', whereArgs: [id]);
    await db.delete(titleName, where: 'card_pk=?', whereArgs: [id]);
  }

  deleteAllCardTitle() async {
    final db = await database;
    await db.rawDelete('DELETE FROM $titleName');
  }

  deleteQCardTitle(int id) async {
    final db = await database;
    await db.delete(titleName, where: 'card_pk=?', whereArgs: [id]);
  }

  updateCardUpdate(int pk, int update) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE $titleName SET getUpdate = ? WHERE pk = ?', [update, pk]);
  }

  updateLikes(int pk, int like) async {
    final db = await database;
    await db
        .rawUpdate('UPDATE $titleName SET likes = ? WHERE pk = ?', [like, pk]);
  }

  updatePercentage(int pk, int percent) async {
    final db = await database;
    await db.rawUpdate(
        'UPDATE $titleName SET percentage = ? WHERE pk = ?', [percent, pk]);
  }

  updateFlag(int pk, int flag) async {
    print("플래그여기");
    final db = await database;
    await db.rawUpdate(
        'UPDATE $titleName SET newFlag = ? WHERE pk = ?', [flag, pk]);
    CardTitle title = await DBHelper().getCardTitle(pk);
    print("플래그");
    print(title.newFlag);
  }

  updateDate(String id) async {
    final db = await database;
    List<CardTitle> list = List<CardTitle>();
    print("안녕");
    CardTitle title;
    list = await DBHelper().getAllCardTitle();
    print(list.length);
    for (int i = 0; i < list.length; i++) {
      print(list[i].newFlag);
      if (id != list[i].userName && list[i].newFlag == 1) {
        title = await getCard(list[i].pk);
        print(list[i].newFlag);
        list[i].date = title.date;
        list[i].newFlag = 0;
        await db.update(titleName, list[i].toJson(),
            where: 'pk=?', whereArgs: [list[i].pk]);
      }
    }
  }

  updateFolderPercent(int pk) async {
    final db = await database;
    List<CardTitle> list = await DBHelper().getQCardTitle(pk);
    int sum = 0;
    int count = 0;
    if (list.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        sum += list[i].percentage;
        count += list[i].count;
      }
      sum = (sum / list.length).round();
      await db.rawUpdate(
          'UPDATE $titleName SET percentage = ? WHERE pk = ?', [sum, pk]);
      await db.rawUpdate(
          'UPDATE $titleName SET count = ? WHERE pk = ?', [count, pk]);
    }
  }
}

class TitleBloc {
  TitleBloc() {
    getTitles();
  }

  final _titleController = StreamController<List<CardTitle>>.broadcast();
  get titles => _titleController.stream;

  dispose() {
    _titleController.close();
  }

  getTitles() async {
    _titleController.sink.add(await DBHelper().getAllCardTitle());
  }

  addTitles(CardTitle cardTitle) async {
    await DBHelper().createData(cardTitle);
    await getTitles();
  }

  deleteCard(int id) async {
    await DBHelper().deleteCardTitle(id);
    getTitles();
  }

  deleteFolders(int id) async {
    await DBHelper().deleteFolder(id);
    getTitles();
  }

  deleteAllTitles() async {
    await DBHelper().deleteAllCardTitle();
    getTitles();
  }

  updateTitles(CardTitle cardTitle) async {
    await DBHelper().updateCardTitle(cardTitle);
    await getTitles();
  }

  updateFlag(int pk, int update) async {
    await DBHelper().updateCardUpdate(pk, update);
    await getTitles();
  }

  updatePercent(int pk, int percent) async {
    await DBHelper().updatePercentage(pk, percent);
    getTitles();
  }

  updateFolderPercents(int pk) async {
    await DBHelper().updateFolderPercent(pk);
    await getTitles();
  }

  updateNewFlag(int pk, int flag) async {
    await DBHelper().updateFlag(pk, flag);
    getTitles();
  }

  updateLike(int pk, int like) async {
    await DBHelper().updateLikes(pk, like);
    getTitles();
  }

  updateDates(String id) async {
    await DBHelper().updateDate(id);
    getTitles();
  }
}

class QCardBloc {
  int num;

  QCardBloc(int num) {
    this.num = num;
    getQCard(num);
  }

  final _QCardController = StreamController<List<CardTitle>>.broadcast();
  get cards => _QCardController.stream;

  dispose() {
    _QCardController.close();
  }

  getQCard(int num) async {
    _QCardController.sink.add(await DBHelper().getQCardTitle(num));
  }

  addCards(CardTitle title) async {
    await DBHelper().createData(title);
    getQCard(num);
  }

  deleteCards(int pk) async {
    await DBHelper().deleteCardTitle(pk);
    getQCard(num);
  }

  deleteAllCards(int id) async {
    await DBHelper().deleteQCardTitle(num);
    getQCard(num);
  }
}
