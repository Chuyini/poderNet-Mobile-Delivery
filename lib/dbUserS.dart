import 'package:podernet/dbUserS.dart';
import 'package:path/path.dart' as path;
import 'package:podernet/user.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

class DbUser {
  static final DbUser _instance = DbUser._internal();
  static sqflite.Database? _database;

  // Constructor privado
  DbUser._internal();

  // Instancia única de la clase DB
  factory DbUser() {
    return _instance;
  }

  // Inicializa la base de datos
  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Crear y configurar la base de datos
  Future<sqflite.Database> _initDB() async {
    final dbPath = await sqflite.getDatabasesPath();
    return await sqflite.openDatabase(
      path.join(dbPath, 'deliveries.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            name TEXT,
            password, TEXT
          )
        ''');
      },
    );
  }

  static Future<sqflite.Database> _openDB() async {
    return sqflite.openDatabase(
      path.join(await sqflite.getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE delivery (id INTEGER PRIMARY KEY AUTOINCREMENT,  name TEXT, password TEXT);');
      },
      version: 1,
    );
  }

  static Future<void> deleteDatabaseUser() async {
    try {
      String dbPath = path.join(await sqflite.getDatabasesPath(), 'user.db');
      await sqflite.deleteDatabase(dbPath);
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> insertUser(User user) async {
    try {
      sqflite.Database db = await _openDB();
      // Convertir el objeto `Delivery` a un mapa, pero sin el campo `id`
      final data = user.toMap();

      // Imprimir los datos del mapa de la entrega
      print("\n La data del mapa es: $data\n");

      await db.insert("delivery", data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteUser(User user) async {
    try {
      sqflite.Database db = await _openDB();
      await db.delete("delivery", where: "id = ?", whereArgs: [user.id]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateUser(User user) async {
    try {
      sqflite.Database db = await _openDB();
      await db.update(
        'delivery',
        user.toMap(),
        where: "id = ?",
        whereArgs: [user.id],
      );
      print("Delivery actualizado: ${user.name}");
      return true;
    } catch (e) {
      print("Error al actualizar el delivery: $e");
      return false;
    }
  }

  static Future<List<User>> getUser() async {
    try {
      sqflite.Database db = await _openDB();
      final List<Map<String, dynamic>> userList = await db.query("delivery");
      return List.generate(
        userList.length,
        (i) => User(
          id: userList[i]["id"] ?? '',
          name: userList[i]["name"] ?? '',
          password: userList[i]["password"] ?? '',
        ),
      );
    } catch (e) {
      print('Error al obtener las entregas: $e');
      return [];
    }
  }
}

void main() async {
  // Crear un nuevo objeto de entrega sin especificar el id
  User user = User(
    id: 23,
    name: "Jesus",
    password: "1235lara"

  );

  // Insertar la entrega en la base de datos
  bool success = await DbUser.insertUser(user);

  if (success) {
    print("Entrega insertada exitosamente.");
  } else {
    print("Error al insertar la entrega.");
  }

  // Obtener todas las entregas
  List<User> users = await DbUser.getUser();
  users.forEach((user) {
    print(user.toMap());
  });
}
