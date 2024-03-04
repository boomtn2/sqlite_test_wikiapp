import 'dart:convert';

import 'book.dart';

class BookInfo {
  Book? book;
  List<Map<String, String>> theLoai;
  String moTa;
  List<Map<String, String>> dsChuong;

  BookInfo({
    this.book,
    required this.theLoai,
    required this.moTa,
    required this.dsChuong,
  });

  toMap() {
    return '{theLoai: $theLoai, moTa: $moTa, dsChuong: $dsChuong}';
  }

  int getIndexChapterInList({required Map<String, String> choose}) {
    for (int i = 0; i < dsChuong.length; ++i) {
      if (dsChuong[i] == choose) {
        return i;
      }
    }
    return 0;
  }
}
