import 'package:flutter/material.dart';
import 'package:sqlite_crud/data_test.dart';
import 'package:sqlite_crud/model/book.dart';
import 'package:sqlite_crud/model/bookinfo.dart';
import 'package:sqlite_crud/sqlite_heper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().db;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Book> history = [];
  List<Book> favorite = [];
  List<BookInfo> offline = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Wrap(
              children: [
                buttonInit(),
                buttonGetData(),
              ],
            ),
            Text('Offline'),
            ViewBookInfo(
              dataList: offline,
              function: (book) {
                final DatabaseHelper helper = DatabaseHelper.internal();

                helper.deleteBookOffline(book.id);
              },
            ),
            Text('History'),
            ViewDataHisTory(
              dataList: history,
              function: (book) {
                final DatabaseHelper helper = DatabaseHelper.internal();
                helper.deleteBookHistory(book.id);
              },
            ),
            Text('favorite'),
            ViewDataHisTory(
              dataList: favorite,
              function: (book) {
                final DatabaseHelper helper = DatabaseHelper.internal();
                helper.deleteBookFavorite(book.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buttonInit() {
    return Wrap(
      children: [
        ElevatedButton(
            onPressed: () {
              final DatabaseHelper helper = DatabaseHelper.internal();
              DataTest.initDataTest(2, 'favorite');

              DataTest.listBookInfor.forEach((element) async {
                await helper.insertBookFavorite(
                    item: element, book: element.book!);
              });
            },
            child: Text('insertBookFavorite')),
        ElevatedButton(
            onPressed: () {
              final DatabaseHelper helper = DatabaseHelper.internal();

              DataTest.initDataTest(2, 'History');
              DataTest.listBookInfor.forEach((element) async {
                await helper.insertBookHistory(
                    item: element, book: element.book!);
                await DatabaseHelper.internal().insertHistory(
                    id: element.book!.id,
                    nameChap: element.book!.history!.nameChapter);
              });
            },
            child: Text('insertBookHistory')),
        ElevatedButton(
            onPressed: () {
              final DatabaseHelper helper = DatabaseHelper.internal();

              DataTest.initDataTest(2, 'Offline');
              DataTest.listBookInfor.forEach((element) async {
                await helper.insertBookOffline(
                    item: element, book: element.book!);
                await helper.insertChapter(
                    id: element.book!.id,
                    nameChapter: 'chapter 1',
                    text: 'data chapter 1');
              });
            },
            child: Text('insertBookOffline')),
        ElevatedButton(
            onPressed: () {
              final DatabaseHelper helper = DatabaseHelper.internal();
              helper.deleteBookALLTABLE();
            },
            child: Text('deleteBookALLTABLE')),
        ElevatedButton(
            onPressed: () {
              final DatabaseHelper helper = DatabaseHelper.internal();
              helper.getALLChapterOffline();
            },
            child: Text('Get ALL CHAPTER')),
        ElevatedButton(
            onPressed: () async {
              final DatabaseHelper helper = DatabaseHelper.internal();
              helper.getListBookOffline();

              final BookOffline = await helper.getListBookOffline();
              List<BookInfo> lsinfo = [];
              for (var element in BookOffline) {
                BookInfo temp = await helper.getBookInfoOffline(book: element);
                lsinfo.add(temp);
              }

              setState(() {
                offline = lsinfo;
              });
            },
            child: Text('Get Book offline')),
      ],
    );
  }

  Widget buttonGetData() {
    return ElevatedButton(
        onPressed: () async {
          final DatabaseHelper helper = DatabaseHelper.internal();

          final BookFavorite = await helper.getListBookFavorite();

          final BookHistory = await helper.getListBookHistory();

          final BookOffline = await helper.getListBookOffline();
          List<BookInfo> lsinfo = [];
          BookOffline.forEach((element) async {
            BookInfo temp = await helper.getBookInfoOffline(book: element);
            lsinfo.add(temp);
          });

          setState(() {
            favorite = BookFavorite;
            offline = lsinfo;
            history = BookHistory;
          });
        },
        child: Text('getdata'));
  }
}

class ViewBookInfo extends StatelessWidget {
  ViewBookInfo({super.key, required this.dataList, required this.function});
  final List<BookInfo> dataList;
  final Function(Book book) function;
  final DatabaseHelper helper = DatabaseHelper.internal();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: dataList.map((e) {
        String id = e.book!.id;
        return InkWell(
          onTap: () {
            function(e.book!);
          },
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e.book!.bookName),
                Text(e.book!.bookPath),
                Text(e.book!.imgPath),
                Divider(),
                e.book!.history == null
                    ? Container()
                    : Text(e.book!.history!.nameChapter),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: e.dsChuong
                      .map((e) => ElevatedButton(
                          onPressed: () {
                            helper.getTextChapterOffline(
                                id: id, nChapter: e.entries.first.key);
                          },
                          child: Text(e.entries.first.key)))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ViewDataHisTory extends StatelessWidget {
  const ViewDataHisTory(
      {super.key, required this.dataList, required this.function});
  final List<Book> dataList;
  final Function(Book book) function;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: dataList
          .map((e) => InkWell(
                onTap: () {
                  function(e);
                },
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.bookName),
                      Text(e.bookPath),
                      Text(e.imgPath),
                      Divider(),
                      e.history == null
                          ? Container()
                          : Text(e.history!.nameChapter),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
