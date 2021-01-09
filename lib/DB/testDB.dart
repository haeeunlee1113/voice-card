import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String testName = 'quIZ';

class TestList{
  String question;
  String answer;
  int num;
  int pk;
  TestList({this.question, this.answer, this.num, this.pk});

  factory TestList.fromJson(Map<String, dynamic> json) => new TestList(
      question : json["question"],
      answer: json["answer"],
      num: json["num"],
      pk: json["pk"],
  );

  Map<String, dynamic> toJson() => {
    "question" : question,
    "answer" : answer,
    "pk" : pk,
  };

  Map<String, dynamic> testToMap() =>{
    "pk": pk,
    "answer" : answer,
    "question" : question,
  };
}

class TestDBHelper {
  TestDBHelper._();

  static final TestDBHelper _db = TestDBHelper._();
  factory TestDBHelper() => _db;
  static Database _database;

  Future<Database> get database async {
    if(_database != null) return _database;

    _database = await testInitDB();
    return _database;
  }

  testInitDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'DB.db');

    return await openDatabase(
      path,
      version: 9,
      onCreate: (Database db, int version) async {

        await db.execute('''
          CREATE TABLE $testName (
            pk INTEGER,
            num INTEGER PRIMARY KEY,
            question TEXT,
            answer TEXT)
          ''');

      },
    );
  }


  createTestData(TestList testList) async {
    final db = await database;
    var res = await db.insert(testName, testList.toJson());
    return res;
  }

  Future<List<TestList>> getTestList(int num) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM $testName WHERE pk=?', [num]);
    List<TestList> list =
    res.isNotEmpty ? res.map((c) => TestList.fromJson(c)).toList() : [];
    return list;
  }

  getAllTestList() async{
    final db = await database;
    var res = await db.query(testName);
    List<TestList> list =
    res.isNotEmpty? res.map((c) => TestList.fromJson(c)).toList() : [];
    return list;
  }


  updateTestList(TestList testList) async {
    print("안녕");
    final db = await database;
    var res = await db.query(testName, where: 'num=?', whereArgs: [testList.num]);
    if(res.isEmpty){
      print("없음");
    }
    else {
      await db.update(testName, testList.toJson(), where: 'num = ?',
          whereArgs: [testList.num]);
    }
  }

  deleteTestList(int num) async {
    final db = await database;
    await db.delete(testName, where: 'num=?', whereArgs: [num]);
  }

  deleteQTestList(int id) async {
    final db = await database;
    await db.delete(testName, where: 'pk=?', whereArgs: [id]);
  }

  deleteAllTestList() async {
    final db = await database;
    db.rawDelete('Delete from $testName');
  }
}

class TestBloc{
  TestBloc(){
    getTestLists();
  }

  final _testController = StreamController<List<TestList>>.broadcast();
  get testLists => _testController.stream;

  dispose(){
    _testController.close();
  }

  getTestLists() async{
    _testController.sink.add(await TestDBHelper().getAllTestList());
  }

  addTestLists(TestList testList) async{
    await TestDBHelper().createTestData(testList);
    getTestLists();
  }

  deleteTestLists(int num) async{
    await TestDBHelper().deleteTestList(num);
    getTestLists();
  }

  deleteQTestLists(int num) async{
    await TestDBHelper().deleteQTestList(num);
    getTestLists();
  }

  deleteAllLists() async{
    await TestDBHelper().deleteAllTestList();
    getTestLists();
  }

  updateTestLists(TestList testList) async{
    await TestDBHelper().updateTestList(testList);
    //getTestLists();
  }
}

class QTestBloc{
  int num;

  QTestBloc(int num){
    this.num = num;
    getQTestLists(num);
  }

  final _QtestController = StreamController<List<TestList>>.broadcast();
  get testLists => _QtestController.stream;

  dispose() {
    _QtestController.close();
  }

  getQTestLists(int num) async {
    _QtestController.sink.add(await TestDBHelper().getTestList(num));
  }

  addTestLists(TestList testList) async{
    await TestDBHelper().createTestData(testList);
    getQTestLists(num);
  }

  deleteTestLists(int id) async{
    await TestDBHelper().deleteTestList(id);
    getQTestLists(num);
  }

  deleteAllTestLists() async{
    await TestDBHelper().deleteQTestList(num);
    getQTestLists(num);
  }


  updateTestLists(TestList testList) async{
    await TestDBHelper().updateTestList(testList);
    getQTestLists(num);
  }

}




