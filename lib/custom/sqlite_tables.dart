// lib/database/create_tables.dart

const String createTblCategories = '''
  CREATE TABLE IF NOT EXISTS tblcategories (
    CategoryID INTEGER PRIMARY KEY,
    CategoryName TEXT,
    LastUpdatedTXID INTEGER DEFAULT 0,
    LastUpdated TEXT,
    DeletedTXID INTEGER DEFAULT NULL
  );
''';

const String createTblProducts = '''
  CREATE TABLE IF NOT EXISTS tblproducts (
    ProductID INTEGER PRIMARY KEY,
    ProductName TEXT,
    CategoryID INTEGER,
    Price REAL,
    FOREIGN KEY (CategoryID) REFERENCES tblcategories(CategoryID)
  );
''';

const String createTblOrders = '''
  CREATE TABLE IF NOT EXISTS tblorders (
    OrderID INTEGER PRIMARY KEY,
    OrderDate TEXT,
    CustomerName TEXT
  );
''';

// Optionally: List of all table creations
const List<String> createTableQueries = [
  createTblCategories,
  createTblProducts,
  createTblOrders,
];
