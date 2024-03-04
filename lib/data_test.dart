import 'package:sqlite_crud/model/book.dart';
import 'package:sqlite_crud/model/bookinfo.dart';

class DataTest {
  static List<Book> listBook = [];

  static List<History> listHistory = [];

  static List<BookInfo> listBookInfor = [];
  static void initDataTest(int countItem, String title) {
    listBookInfor = [];
    for (int i = 0; i < countItem; ++i) {
      final history = History(
          nameChapter: 'chapter$i',
          chapterPath: 'chapterPath$i',
          text: 'noi dung la: $i');
      Map<String, String> theLoai = {'theloai$i': 'theloai$i'};
      List<Map<String, String>> lsTheLoai = [theLoai];
      Map<String, String> chapter = {'Chapter$i': 'Chapter$i'};
      List<Map<String, String>> lsChapter = [chapter];
      listBookInfor.add(BookInfo(
          theLoai: lsTheLoai,
          moTa: '',
          dsChuong: lsChapter,
          book: Book(
              history: history,
              imgPath: 'imgPath$i',
              bookPath: 'bookPath$i',
              bookName: 'bookName$i$title',
              bookAuthor: 'bookAuthor$i',
              bookPublisher: 'bookPublisher$i',
              bookViews: 'bookViews$i',
              bookStar: 'bookStar$i',
              bookComment: 'bookComment$i')));
    }
  }
}
