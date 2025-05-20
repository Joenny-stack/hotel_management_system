import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final int? id;
  final String username;
  final String password;
  final String role; // 'admin', 'staff', 'housekeeping'
  final String? fullName;
  final String? email;
  final String? createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    required this.role,
    this.fullName,
    this.email,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role,
      'full_name': fullName,
      'email': email,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      role: map['role'],
      fullName: map['full_name'],
      email: map['email'],
      createdAt: map['created_at'],
    );
  }
}

class Room {
  final int? id;
  final String roomNumber;
  final String type;
  final String status;
  final double pricePerNight;
  final String? imagePath;
  final String? housekeepingStatus;
  final String? roomClass;

  Room({
    this.id,
    required this.roomNumber,
    required this.type,
    required this.status,
    required this.pricePerNight,
    this.imagePath,
    this.housekeepingStatus,
    this.roomClass,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_number': roomNumber,
      'type': type,
      'status': status,
      'price_per_night': pricePerNight,
      'image_path': imagePath,
      'housekeeping_status': housekeepingStatus,
      'room_class': roomClass,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      roomNumber: map['room_number'],
      type: map['type'],
      status: map['status'],
      pricePerNight: map['price_per_night'] is int ? (map['price_per_night'] as int).toDouble() : map['price_per_night'],
      imagePath: map['image_path'],
      housekeepingStatus: map['housekeeping_status'],
      roomClass: map['room_class'],
    );
  }
}

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hotel_management.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            role TEXT NOT NULL,
            full_name TEXT,
            email TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
        // Insert default admin and staff
        await db.insert('users', {
          'username': 'admin',
          'password': 'admin123',
          'role': 'admin',
          'full_name': 'Admin User',
          'email': 'admin@hotel.com',
        });
        await db.insert('users', {
          'username': 'staff',
          'password': 'staff123',
          'role': 'staff',
          'full_name': 'Staff User',
          'email': 'staff@hotel.com',
        });
        await db.insert('users', {
          'username': 'housekeeping',
          'password': 'house123',
          'role': 'housekeeping',
          'full_name': 'Housekeeping User',
          'email': 'housekeeping@hotel.com',
        });
        await db.execute('''
          CREATE TABLE rooms(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            room_number TEXT NOT NULL UNIQUE,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            price_per_night REAL NOT NULL,
            image_path TEXT,
            housekeeping_status TEXT DEFAULT 'clean',
            room_class TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE users ADD COLUMN full_name TEXT;");
          await db.execute("ALTER TABLE users ADD COLUMN email TEXT;");
          await db.execute("ALTER TABLE users ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP;");
        }
        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS rooms(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              room_number TEXT NOT NULL UNIQUE,
              type TEXT NOT NULL,
              status TEXT NOT NULL,
              price_per_night REAL NOT NULL,
              image_path TEXT,
              housekeeping_status TEXT DEFAULT 'clean',
              room_class TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<User?> getUser(String username, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (res.isNotEmpty) {
      return User.fromMap(res.first);
    }
    return null;
  }

  static Future<int> insertRoom(Room room) async {
    final db = await database;
    return await db.insert('rooms', room.toMap());
  }

  static Future<List<Room>> getRooms() async {
    final db = await database;
    final res = await db.query('rooms');
    return res.map((e) => Room.fromMap(e)).toList();
  }

  static Future<int> updateRoom(Room room) async {
    final db = await database;
    return await db.update('rooms', room.toMap(), where: 'id = ?', whereArgs: [room.id]);
  }

  static Future<int> deleteRoom(int id) async {
    final db = await database;
    return await db.delete('rooms', where: 'id = ?', whereArgs: [id]);
  }
}
