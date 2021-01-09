import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:voicequiz/DB/titleDB.dart';
import 'package:voicequiz/DB/testDB.dart';
import 'dart:io';
import 'package:dio/dio.dart';

final String url = "http://15.164.206.95:5000";

loginServer() async {
  String userName = await getId();
  await http.get(url + "/login/" + userName + "/");
}

uploadNewData(CardTitle cardTitle, List<TestList> testList) async {
  String userName = await getId();
  cardTitle.userName = userName;
  cardTitle.pk = 0;
  TitleBloc titleBloc = TitleBloc();
  TestBloc testBloc = TestBloc();
  TestList newList;
  FormData formData = FormData.fromMap(cardTitle.titleToMap());
  int num;
  var response = await Dio().post(url + "/card/", data: formData);
  print(response.data);
  if (response.data == "no")
    print("card error");
  else {
    num = int.parse(response.data);
    newList = testList[testList.length - 1];
    if (newList.question.isEmpty || newList.answer.isEmpty)
      testList.removeLast();
    int length = testList.length;
    for (int i = 0; i < testList.length; i++) {
      testList[i].pk = num;
      formData = FormData.fromMap(testList[i].testToMap());
      response = await Dio().post(
        url + "/quiz/",
        data: formData,
      );
      print(response.data);
      if (length < testList.length) testList.removeLast();
      if (response.data == "no") {
        print("quiz error");
        break;
      } else
        testBloc.addTestLists(testList[i]);
    }
    cardTitle = await getCard(num);
    cardTitle.toggle = 1;
    cardTitle.getUpdate = 1;
    cardTitle.percentage = 0;
    cardTitle.studyDate = cardTitle.date;
    cardTitle.newFlag = 0;
    if (cardTitle.folder)
      cardTitle.dbFolder = 1;
    else
      cardTitle.dbFolder = 0;
    await titleBloc.addTitles(cardTitle);
  }
}

updateData(CardTitle cardTitle, List<TestList> testList) async {
  CardTitle serverFolder;
  CardTitle dBFolder;
  TitleBloc titleBloc = TitleBloc();
  FormData formData = FormData.fromMap(cardTitle.titleToMap());
  var response = await Dio().post(url + "/card/", data: formData);
  int num;
  int update = cardTitle.getUpdate;
  int folder = cardTitle.dbFolder;
  int toggle = cardTitle.toggle;
  String date = cardTitle.studyDate;
  if (response.data == "no")
    print("card error");
  else {
    num = int.parse(response.data);
    print(num);
    await deleteQuiz(num);
    int length = testList.length;
    for (int i = 0; i < testList.length; i++) {
      formData = FormData.fromMap(testList[i].testToMap());
      response = await Dio().post(
        url + "/quiz/",
        data: formData,
      );
      if (response.data == "no") {
        print("quiz error");
        break;
      }
      if (length < testList.length) testList.removeLast();
    }
    cardTitle = await getCard(num);
    cardTitle.getUpdate = update;
    cardTitle.percentage = 0;
    cardTitle.dbFolder = folder;
    cardTitle.toggle = toggle;
    cardTitle.studyDate = date;
    cardTitle.newFlag = 0;
    await titleBloc.updateTitles(cardTitle);
    if (cardTitle.id != 0) {
     /* dBFolder = await DBHelper().getCardTitle(cardTitle.id);
      dBFolder.tag = dBFolder.tag.replaceAll("#", " ");
      formData = FormData.fromMap(dBFolder.titleToMap());
      response = await Dio().post(
        url + "/quiz/",
        data: formData,
      );
      serverFolder = await getCard(cardTitle.id);
      dBFolder.date = serverFolder.date;
      dBFolder.count = serverFolder.count;
      dBFolder.tag = serverFolder.tag;
      await titleBloc.updateTitles(dBFolder);*/
     await DBHelper().updateFolderPercent(cardTitle.id);
    }
  }
}

deleteCard(int pk) async {
  final response = await http.get(url + "/delete/" + pk.toString() + "/");
  if (response.body == "ok") {
    return true;
  } else
    return false;
}

deleteQuiz(int pk) async {
  final response = await http.get(url + "/delete/quiz/" + pk.toString() + "/");
}

Future<List<TestList>> getQuiz(int pk) async {
  final response = await http.get(url + "/getQuiz/" + pk.toString() + "/");
  final List<TestList> list = jsonDecode(response.body)
      .map<TestList>((json) => TestList.fromJson(json))
      .toList();
  return list;
}

Future<CardTitle> getCard(int pk) async {
  final response = await http.get(url + "/getCard/" + pk.toString() + "/");
  return CardTitle.fromServerJson(jsonDecode(response.body));
}

Future<List<CardTitle>> search(String title) async {
  String userName = await getId();
  var response =
      await http.get(url + "/search/" + userName + "/" + title + "/");
  final List<CardTitle> list = jsonDecode(response.body)
      .map<CardTitle>((json) => CardTitle.fromSearchJson(json))
      .toList();
  return list;
}

likes(int pk, int toggle) async {
  var response = await http
      .get(url + "/likes/" + pk.toString() + "/" + toggle.toString() + "/");
}

makeFolderCard(CardTitle folderCard, CardTitle firstCard, CardTitle secondCard) async {
  String userName = await getId();
  int num;
  folderCard.userName = userName;
  FormData formData = FormData.fromMap(folderCard.titleToMap());
  var response = await Dio().post(
    url + "/card/",
    data: formData,
  );
  if (response.data == "no")
    print("card error");
  else {
    num = int.parse(response.data);
    folderCard.pk = num;
    await addFolder(num, firstCard, folderCard, true);
    folderCard = await DBHelper().getCardTitle(num);
    await addFolder(num, secondCard, folderCard, false);
  }
}

addFolder(int cardPk, CardTitle card, CardTitle folder, bool first) async {
  TitleBloc titleBloc = TitleBloc();
  String userName = await getId();
  await http.get(url + "/make/" + cardPk.toString() + "/" + card.pk.toString() + "/" + userName + "/");
  CardTitle folderCard = await getCard(cardPk);
  if (first) {
    folder.date = folderCard.date;
    folder.studyDate = folderCard.date;
    await titleBloc.addTitles(folder);
  }
  else {
    folder.studyDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await titleBloc.updateTitles(folder);
  }
  card.id = cardPk;
  await titleBloc.updateTitles(card);
  await titleBloc.updateFolderPercents(cardPk);
}

Future<List<CardTitle>> getFolder(int cardPk) async {
  var response =
      await http.get(url + "/folder/card/" + cardPk.toString() + "/");
  final List<CardTitle> list = jsonDecode(response.body)
      .map<CardTitle>((json) => CardTitle.fromServerJson(json))
      .toList();
  return list;
}

updateFolderCard(CardTitle cardTitle) async {
  TitleBloc titleBloc = TitleBloc();
  FormData formData = FormData.fromMap(cardTitle.titleToMap());
  var response = await Dio().post(url + "/card/", data: formData);
  if (response.data == "no")
    print("card error");
  else
    await titleBloc.updateTitles(cardTitle);
}

Future<String> getId() async {
  final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
  if (Platform.isIOS) {
    var ios = await deviceInfoPlugin.iosInfo;
    return ios.identifierForVendor;
  } else if (Platform.isAndroid) {
    var android = await deviceInfoPlugin.androidInfo;
    return android.androidId;
  } else
    return null;
}
