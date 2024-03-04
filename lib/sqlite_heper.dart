import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'model/book.dart';
import 'model/bookinfo.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper.internal();

  final String nameDB = 'datatestnew.db';
  // Tên của bảng và các cột
  final String tableBookFavorite = 'book_favorite';
  final String tableBookHistory = 'book_history';
  final String tableBook = 'book_offline';
  final String columnId = 'id';
  final String imgPath = 'imgPath';
  final String bookName = 'bookName';
  final String bookAuthor = 'bookAuthor';
  final String bookPath = 'bookPath';
  final String theLoai = 'theLoai';
  final String moTa = 'moTa';

  final String tableChapter = 'chapter_offline';
  final String nameChapter = 'nameChapter';
  final String textChapter = 'textChapter';

  final String tableHistory = 'history';
  //nameChapter

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, nameDB);
    var myDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    if (kDebugMode) print('initDb');
    return myDb;
  }

  void _onCreate(Database db, int newVersion) async {
    await _execute(
        'CREATE TABLE $tableBook($columnId TEXT PRIMARY KEY ,$imgPath TEXT,$bookName TEXT,$bookAuthor TEXT,$moTa TEXT, $theLoai TEXT, $bookPath TEXT)',
        db);
    await _execute(
        'CREATE TABLE $tableBookFavorite($columnId TEXT PRIMARY KEY ,$imgPath TEXT,$bookName TEXT,$bookAuthor TEXT,$moTa TEXT, $theLoai TEXT, $bookPath TEXT)',
        db);

    await _execute(
        'CREATE TABLE $tableBookHistory($columnId TEXT PRIMARY KEY ,$imgPath TEXT,$bookName TEXT,$bookAuthor TEXT,$moTa TEXT, $theLoai TEXT, $bookPath TEXT)',
        db);

    await _execute(
        'CREATE TABLE $tableChapter($columnId TEXT,$nameChapter TEXT,$textChapter TEXT )',
        db);
    await _execute(
        'CREATE TABLE $tableHistory($columnId TEXT PRIMARY KEY,$nameChapter TEXT)',
        db);
  }

  Future _execute(String query, Database db) async {
    await db.execute(query);
    if (kDebugMode) print('init: $query');
  }

  Future<int> _insertDB(String tableName, Map<String, Object?> data) async {
    try {
      var dbClient = await db;
      int response = await dbClient!.insert(tableName, data);
      _showDebugCode(response, '_insertDB $tableName');
      return response;
    } catch (e) {
      if (kDebugMode) print('insert table {$tableName} Error: \n {$e}');
      return 0;
    }
  }

  void _showDebugCode(int code, String title) {
    if (kDebugMode) {
      code != 0 ? print('$title {success $code row}') : print('$title {false}');
    }
  }

  Future<int> _deleteDB(
      String tableName, String? where, List<Object?>? args) async {
    try {
      var dbClient = await db;
      dbClient!.close();
      int response =
          await dbClient!.delete(tableName, where: where, whereArgs: args);
      _showDebugCode(response, '_deleteDB $tableName');
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
      return 0;
    }
  }

  void close() async {
    var dbClient = await db;
    await dbClient!.close();
  }

  Future<List<Map<String, dynamic>>> _getDB(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      var dbClient = await db;
      final List<Map<String, dynamic>> dataList = await dbClient!.query(
        table,
        distinct: distinct,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      if (kDebugMode)
        print('GetDB $table {$where} {$whereArgs}: \n {$dataList}');
      return dataList;
    } catch (e) {
      if (kDebugMode) print('GetDB $table Error: \n{$e}');
      return [];
    }
  }

  // Thêm dữ liệu
  Future<int> insertBookOffline(
      {required BookInfo item, required Book book}) async {
    return _insertDB(tableBook, {
      columnId: book.id,
      imgPath: book.imgPath,
      bookName: book.bookName,
      bookAuthor: book.bookAuthor,
      bookPath: book.bookPath,
      theLoai: jsonEncode(item.theLoai),
      moTa: item.moTa
    });
  }

  Future<int> insertBookHistory(
      {required BookInfo item, required Book book}) async {
    return await _insertDB(tableBookHistory, {
      columnId: book.id,
      imgPath: book.imgPath,
      bookName: book.bookName,
      bookAuthor: book.bookAuthor,
      bookPath: book.bookPath,
      theLoai: jsonEncode(item.theLoai),
      moTa: item.moTa
    });
  }

  Future<int> insertBookFavorite(
      {required BookInfo item, required Book book}) async {
    return _insertDB(tableBookFavorite, {
      columnId: book.id,
      imgPath: book.imgPath,
      bookName: book.bookName,
      bookAuthor: book.bookAuthor,
      bookPath: book.bookPath,
      theLoai: jsonEncode(item.theLoai),
      moTa: item.moTa
    });
  }

  Future<int> insertChapter(
      {required String id,
      required String nameChapter,
      required String text}) async {
    int isCheck = await daTonTai(id, tableBook);
    if (isCheck == 1) {
      return _insertDB(tableChapter, {
        columnId: id,
        this.nameChapter: nameChapter,
        textChapter: text,
      });
    } else {
      return 0;
    }
  }

  Future<int> insertHistory(
      {required String id, required String nameChap}) async {
    int isCheck = await daTonTai(id, tableBookHistory);
    if (isCheck == 1) {
      return _insertDB(tableHistory, {
        columnId: id,
        this.nameChapter: nameChap,
      });
    } else {
      return 0;
    }
  }

  // Xóa dữ liệu
  Future<int> deleteBookOffline(String id) async {
    await deleteChapter(id);
    return _deleteDB(tableBook, '$columnId = ?', [id]);
  }

  Future<int> deleteBookFavorite(String id) async {
    return _deleteDB(tableBookFavorite, '$columnId = ?', [id]);
  }

  Future<int> deleteBookHistory(String id) async {
    deleteHistory(id);
    return _deleteDB(tableBookHistory, '$columnId = ?', [id]);
  }

  Future<int> deleteHistory(String id) async {
    return _deleteDB(tableHistory, '$columnId = ?', [id]);
  }

  Future<int> deleteChapter(String id) async {
    return _deleteDB(tableChapter, '$columnId = ?', [id]);
  }

  Future deleteBookALLTABLE() async {
    await _deleteDB(tableBookHistory, null, null);
    await _deleteDB(tableBookFavorite, null, null);
    await _deleteDB(tableBook, null, null);
    await _deleteDB(tableChapter, null, null);
    await _deleteDB(tableHistory, null, null);
  }

  Future<List<Book>> getListBookOffline() async {
    List<Book> lsBook = [];

    final List<Map<String, dynamic>> dataList = await _getDB(tableBook);

    for (var element in dataList) {
      lsBook.add(Book(
          imgPath: element[imgPath],
          bookPath: element[bookPath],
          bookName: element[bookName],
          bookAuthor: element[bookAuthor],
          bookPublisher: '',
          bookViews: 'Đã Tải Về',
          bookStar: '',
          bookComment: ''));
    }

    return lsBook;
  }

  Future<List<Book>> getListBookFavorite() async {
    List<Book> lsBook = [];

    final List<Map<String, dynamic>> dataList = await _getDB(tableBookFavorite);

    for (var element in dataList) {
      lsBook.add(Book(
          imgPath: element[imgPath],
          bookPath: element[bookPath],
          bookName: element[bookName],
          bookAuthor: element[bookAuthor],
          bookPublisher: '',
          bookViews: 'Đã Tải Về',
          bookStar: '',
          bookComment: ''));
    }

    return lsBook;
  }

  Future<List<Book>> getListBookHistory() async {
    List<Book> lsBook = [];

    final List<Map<String, dynamic>> dataList = await _getDB(tableBookHistory);

    for (var element in dataList) {
      Book book = Book(
          imgPath: element[imgPath],
          bookPath: element[bookPath],
          bookName: element[bookName],
          bookAuthor: element[bookAuthor],
          bookPublisher: '',
          bookViews: 'History',
          bookStar: '',
          bookComment: '');
      book.history = await getHistory(id: element[columnId]);

      lsBook.add(book);
    }

    return lsBook;
  }

  Future<BookInfo> getBookInfoOffline({required Book book}) async {
    BookInfo bookInfo = BookInfo(theLoai: [], moTa: moTa, dsChuong: []);
    bookInfo.book = book;
    try {
      final List<Map<String, dynamic>> dataList = await _getDB(tableBook,
          columns: [moTa, theLoai],
          where: '$columnId = ?',
          whereArgs: [book.id]);

      final List<Map<String, dynamic>> listNameChuong = await _getDB(
          tableChapter,
          columns: [nameChapter],
          where: '$columnId = ?',
          whereArgs: [book.id]);

      if (dataList.isNotEmpty) {
        List listTheMoai = jsonDecode(dataList.first[theLoai].toString());

        for (Map element in listTheMoai) {
          String key = element.keys.first.toString();
          String value = element.values.first.toString();
          bookInfo.theLoai.add({key: value});
        }

        for (var chapter in listNameChuong) {
          bookInfo.dsChuong.add({chapter[nameChapter]: ''});
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }

    return bookInfo;
  }

  Future<History?> getHistory({required String id}) async {
    final List<Map<String, dynamic>> dataList = await _getDB(tableHistory,
        columns: [nameChapter], where: '$columnId = ?', whereArgs: [id]);
    if (dataList.isEmpty) {
      return null;
    } else {
      String text = dataList.first[nameChapter];
      return History(nameChapter: text, chapterPath: '', text: '');
    }
  }

  Future<String> getTextChapterOffline(
      {required String id, required String nChapter}) async {
    try {
      final dataList = await _getDB(tableChapter,
          columns: [textChapter],
          where: '$columnId = ? AND $nameChapter Like ?',
          whereArgs: [id, nChapter]);
      String text = '${dataList.first[textChapter]}';
      return text;
    } catch (e) {
      return '';
    }
  }

  Future getALLChapterOffline() async {
    await _getDB(tableChapter);
  }

  Future<int> daTonTai(String id, String tableName) async {
    final data =
        await _getDB(tableName, where: '$columnId = ?', whereArgs: [id]);

    if (data.isEmpty) {
      _showDebugCode(0, 'daTonTai $tableName:');
      return 0;
    } else {
      _showDebugCode(1, 'daTonTai $tableName:');
      return 1;
    }
  }
}
