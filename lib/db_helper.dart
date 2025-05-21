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

class Booking {
  final int? id;
  final int guestId;
  final int roomId;
  final String checkInDate;
  final String checkOutDate;
  final String bookingStatus;
  final double? totalAmount;
  final String? paymentStatus;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Booking({
    this.id,
    required this.guestId,
    required this.roomId,
    required this.checkInDate,
    required this.checkOutDate,
    this.bookingStatus = 'pending',
    this.totalAmount,
    this.paymentStatus = 'unpaid',
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Booking copyWith({
    int? id,
    int? guestId,
    int? roomId,
    String? checkInDate,
    String? checkOutDate,
    String? bookingStatus,
    double? totalAmount,
    String? paymentStatus,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      guestId: guestId ?? this.guestId,
      roomId: roomId ?? this.roomId,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guest_id': guestId,
      'room_id': roomId,
      'check_in_date': checkInDate,
      'check_out_date': checkOutDate,
      'booking_status': bookingStatus,
      'total_amount': totalAmount,
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      guestId: map['guest_id'],
      roomId: map['room_id'],
      checkInDate: map['check_in_date'],
      checkOutDate: map['check_out_date'],
      bookingStatus: map['booking_status'] ?? 'pending',
      totalAmount: map['total_amount'] is int ? (map['total_amount'] as int).toDouble() : map['total_amount'],
      paymentStatus: map['payment_status'] ?? 'unpaid',
      notes: map['notes'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}

class Guest {
  final int? id;
  final String fullName;
  final String? phone;
  final String? email;
  final String? idNumber;
  final String? preferences;
  final String? notes;
  final String? createdAt;

  Guest({
    this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.idNumber,
    this.preferences,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'id_number': idNumber,
      'preferences': preferences,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory Guest.fromMap(Map<String, dynamic> map) {
    return Guest(
      id: map['id'],
      fullName: map['full_name'],
      phone: map['phone'],
      email: map['email'],
      idNumber: map['id_number'],
      preferences: map['preferences'],
      notes: map['notes'],
      createdAt: map['created_at'],
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

  static Future<void> _initAllTables(Database db) async {
    // --- USERS TABLE ---
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        full_name TEXT,
        email TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    // --- ROOMS TABLE ---
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
    // --- GUESTS TABLE ---
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        id_number TEXT,
        preferences TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    // --- BOOKINGS TABLE ---
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        check_in_date TEXT NOT NULL,
        check_out_date TEXT NOT NULL,
        booking_status TEXT DEFAULT 'pending',
        total_amount REAL,
        payment_status TEXT DEFAULT 'unpaid',
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT,
        FOREIGN KEY (guest_id) REFERENCES guests(id),
        FOREIGN KEY (room_id) REFERENCES rooms(id)
      )
    ''');
    // --- BOOKING HISTORY TABLE ---
    await db.execute('''
      CREATE TABLE IF NOT EXISTS booking_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL,
        guest_id INTEGER,
        room_id INTEGER,
        check_in_date TEXT,
        check_out_date TEXT,
        total_amount REAL,
        payment_status TEXT,
        status TEXT NOT NULL,
        changed_at TEXT DEFAULT CURRENT_TIMESTAMP,
        notes TEXT,
        FOREIGN KEY (booking_id) REFERENCES bookings(id)
      )
    ''');
    // --- PAYMENTS TABLE ---
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id INTEGER NOT NULL,
        amount REAL,
        payment_method TEXT,
        payment_date TEXT,
        status TEXT,
        FOREIGN KEY (booking_id) REFERENCES bookings(id)
      )
    ''');
    // --- NOTIFICATIONS TABLE ---
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        message TEXT,
        role TEXT,
        room_id INTEGER,
        created_at TEXT,
        is_read INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'hotel_management.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _initAllTables(db);
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
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _initAllTables(db);
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

class BookingDB {
  static Future<int> insertBooking(Booking booking) async {
    final db = await DBHelper.database;
    return await db.insert('bookings', booking.toMap());
  }

  static Future<List<Booking>> getBookings({String? status}) async {
    final db = await DBHelper.database;
    final res = await db.query('bookings', where: status != null ? 'booking_status = ?' : null, whereArgs: status != null ? [status] : null, orderBy: 'check_in_date DESC');
    return res.map((e) => Booking.fromMap(e)).toList();
  }

  static Future<int> updateBooking(Booking booking) async {
    final db = await DBHelper.database;
    return await db.update('bookings', booking.toMap(), where: 'id = ?', whereArgs: [booking.id]);
  }

  static Future<int> deleteBooking(int id) async {
    final db = await DBHelper.database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> insertBookingHistory(Booking booking) async {
    final db = await DBHelper.database;
    await db.insert('booking_history', {
      'booking_id': booking.id,
      'guest_id': booking.guestId,
      'room_id': booking.roomId,
      'check_in_date': booking.checkInDate,
      'check_out_date': booking.checkOutDate,
      'total_amount': booking.totalAmount,
      'payment_status': booking.paymentStatus,
      'status': booking.bookingStatus,
      'notes': booking.notes,
      'changed_at': DateTime.now().toIso8601String(),
    });
  }

  /// Returns bookings for a room that overlap with the given date range, excluding a booking by id if provided.
  static Future<List<Booking>> getBookingsForRoomInRange(
    int roomId,
    String checkInDate,
    String checkOutDate, {
    int? excludeBookingId,
  }) async {
    final db = await DBHelper.database;
    // Overlap logic: (existing.check_in < new.checkOut) && (existing.check_out > new.checkIn)
    final where = StringBuffer('room_id = ? AND check_in_date < ? AND check_out_date > ?');
    final whereArgs = [roomId, checkOutDate, checkInDate];
    if (excludeBookingId != null) {
      where.write(' AND id != ?');
      whereArgs.add(excludeBookingId);
    }
    final res = await db.query('bookings', where: where.toString(), whereArgs: whereArgs);
    return res.map((e) => Booking.fromMap(e)).toList();
  }
}

class GuestDB {
  static Future<int> insertGuest(Guest guest) async {
    final db = await DBHelper.database;
    return await db.insert('guests', guest.toMap());
  }

  static Future<List<Guest>> getGuests() async {
    final db = await DBHelper.database;
    final res = await db.query('guests', orderBy: 'full_name ASC');
    return res.map((e) => Guest.fromMap(e)).toList();
  }

  static Future<int> updateGuest(Guest guest) async {
    final db = await DBHelper.database;
    return await db.update('guests', guest.toMap(), where: 'id = ?', whereArgs: [guest.id]);
  }

  static Future<int> deleteGuest(int id) async {
    final db = await DBHelper.database;
    return await db.delete('guests', where: 'id = ?', whereArgs: [id]);
  }
}
