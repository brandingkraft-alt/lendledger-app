import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/loan.dart';
import '../models/borrower.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lendledger.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Borrowers table
    await db.execute('''
      CREATE TABLE borrowers (
        borrower_id $idType,
        user_id $textType,
        name $textType,
        phone TEXT,
        email TEXT,
        address TEXT,
        notes TEXT,
        created_at $textType,
        updated_at $textType
      )
    ''');

    // Loans table
    await db.execute('''
      CREATE TABLE loans (
        loan_id $idType,
        user_id $textType,
        borrower_id $textType,
        principal_amount $realType,
        interest_rate $realType,
        interest_rate_type $textType,
        payment_frequency $textType,
        fund_source $textType,
        transaction_mode $textType,
        cost_of_capital REAL,
        original_fund_source TEXT,
        source_converted_at TEXT,
        source_conversion_notes TEXT,
        loan_start_date $textType,
        due_date $textType,
        status $textType,
        created_at $textType,
        updated_at $textType,
        FOREIGN KEY (borrower_id) REFERENCES borrowers (borrower_id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        payment_id $idType,
        loan_id $textType,
        payment_amount $realType,
        principal_paid $realType,
        interest_paid $realType,
        payment_date $textType,
        payment_mode TEXT,
        notes TEXT,
        created_at $textType,
        FOREIGN KEY (loan_id) REFERENCES loans (loan_id)
      )
    ''');
  }

  Future<void> initialize() async {
    await database;
  }

  // Borrower CRUD
  Future<String> createBorrower(Borrower borrower) async {
    final db = await database;
    await db.insert('borrowers', borrower.toMap());
    return borrower.borrowerId;
  }

  Future<Borrower?> getBorrower(String id) async {
    final db = await database;
    final maps = await db.query(
      'borrowers',
      where: 'borrower_id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Borrower.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Borrower>> getAllBorrowers(String userId) async {
    final db = await database;
    final maps = await db.query(
      'borrowers',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );

    return maps.map((map) => Borrower.fromMap(map)).toList();
  }

  // Loan CRUD
  Future<String> createLoan(Loan loan) async {
    final db = await database;
    await db.insert('loans', loan.toMap());
    return loan.loanId;
  }

  Future<Loan?> getLoan(String id) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT l.*, b.name as borrower_name, b.phone as borrower_phone
      FROM loans l
      JOIN borrowers b ON l.borrower_id = b.borrower_id
      WHERE l.loan_id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return Loan.fromMap(
        maps.first,
        borrowerName: maps.first['borrower_name'] as String,
        borrowerPhone: maps.first['borrower_phone'] as String?,
      );
    }
    return null;
  }

  Future<List<Loan>> getAllLoans(String userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT l.*, b.name as borrower_name, b.phone as borrower_phone
      FROM loans l
      JOIN borrowers b ON l.borrower_id = b.borrower_id
      WHERE l.user_id = ?
      ORDER BY l.due_date ASC
    ''', [userId]);

    return maps.map((map) => Loan.fromMap(
      map,
      borrowerName: map['borrower_name'] as String,
      borrowerPhone: map['borrower_phone'] as String?,
    )).toList();
  }

  Future<List<Loan>> getActiveLoans(String userId) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT l.*, b.name as borrower_name, b.phone as borrower_phone
      FROM loans l
      JOIN borrowers b ON l.borrower_id = b.borrower_id
      WHERE l.user_id = ? AND l.status = 'active'
      ORDER BY l.due_date ASC
    ''', [userId]);

    return maps.map((map) => Loan.fromMap(
      map,
      borrowerName: map['borrower_name'] as String,
      borrowerPhone: map['borrower_phone'] as String?,
    )).toList();
  }

  Future<int> updateLoan(Loan loan) async {
    final db = await database;
    return await db.update(
      'loans',
      loan.toMap(),
      where: 'loan_id = ?',
      whereArgs: [loan.loanId],
    );
  }

  Future<int> deleteLoan(String id) async {
    final db = await database;
    return await db.delete(
      'loans',
      where: 'loan_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
