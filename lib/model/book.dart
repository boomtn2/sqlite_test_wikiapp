class Book {
  String imgPath;
  String bookPath;
  String bookName;
  String bookAuthor;
  String bookPublisher;
  String bookViews;
  String bookStar;
  String bookComment;
  History? history;
  String baseUrl = 'https://wikisach.net/';
  Book(
      {required this.imgPath,
      required this.bookPath,
      required this.bookName,
      required this.bookAuthor,
      required this.bookPublisher,
      required this.bookViews,
      required this.bookStar,
      required this.bookComment,
      this.history});

  String get imgFullPath => baseUrl + imgPath;
  String get bookFullPath => baseUrl + bookPath;
  String get id => bookName + bookAuthor;
  factory Book.json(Map<dynamic, dynamic> json) {
    return Book(
        imgPath: json['imgPath'],
        bookPath: json['bookPath'],
        bookName: json['bookName'],
        bookAuthor: json['bookAuthor'],
        bookPublisher: json['bookPublisher'],
        bookViews: json['bookPublisher'],
        bookStar: json['bookPublisher'],
        bookComment: json['bookPublisher'],
        history:
            json['history'] == null ? null : History.json(json['history']));
  }
  Map<String, dynamic> toMap() {
    return {
      'imgPath': imgPath,
      'bookPath': bookPath,
      'bookName': bookName,
      'bookAuthor': bookAuthor,
      'bookPublisher': bookPublisher,
      'bookViews': bookViews,
      'bookStar': bookStar,
      'bookComment': bookComment,
    };
  }

  Map<String, dynamic> toMapFullOption() {
    return {
      'imgPath': imgPath,
      'bookPath': bookPath,
      'bookName': bookName,
      'bookAuthor': bookAuthor,
      'bookPublisher': bookPublisher,
      'bookViews': bookViews,
      'bookStar': bookStar,
      'bookComment': bookComment,
      'history': history?.toMap(),
    };
  }
}

class History {
  String nameChapter;
  String chapterPath;
  String text;

  History(
      {required this.nameChapter,
      required this.chapterPath,
      required this.text});
  Map<String, dynamic> toMap() {
    return {
      'nameChapter': nameChapter,
      'chapterPath': chapterPath,
      'text': text,
    };
  }

  factory History.json(Map<dynamic, dynamic> json) {
    return History(
        nameChapter: json['nameChapter'],
        chapterPath: json['chapterPath'],
        text: json['text']);
  }
}
