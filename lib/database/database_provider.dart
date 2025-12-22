import 'package:sqflite_common/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  late final Future<Database> db = createDatabase();

  Future<Database> createDatabase() async {
    return await openDatabase(
      'Books.db',
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE booksTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            subtitle TEXT,
            author TEXT,
            description TEXT,
            book_type TEXT,
            status INTEGER,
            rating INTEGER,
            favourite INTEGER,
            deleted INTEGER,
            start_date TEXT,
            finish_date TEXT,
            pages INTEGER,
            publication_year INTEGER,
            isbn TEXT,
            olid TEXT,
            tags TEXT,
            my_review TEXT,
            notes TEXT,
            has_cover INTEGER DEFAULT 0,
            blur_hash TEXT,
            readings TEXT,
            date_added TEXT,
            date_modified TEXT
          )
        ''');
      },
    );
  }
}