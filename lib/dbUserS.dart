import 'package:path/path.dart' as path;
import 'package:podernet4/user.dart';
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




  static Future<sqflite.Database> _openDB() async {
    return sqflite.openDatabase(
      path.join(await sqflite.getDatabasesPath(), 'users.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT,  name TEXT, password TEXT);');
      },
      version: 2,
    );
  }

  static Future<void> deleteDatabaseUser() async {
    try {
      String dbPath = path.join(await sqflite.getDatabasesPath(), 'users.db');
      await sqflite.deleteDatabase(dbPath);
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> insertUser(User user) async {
    try {
      sqflite.Database db = await _openDB();
      // Convertir el objeto user a un mapa, pero sin el campo id
      final data = user.toMapWithoutId();


      // Imprimir los datos del mapa de la entrega
      print("\n La data del mapa es: $data\n");

      await db.insert("users", data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteUser(User user) async {
    try {
      sqflite.Database db = await _openDB();
      await db.delete("users", where: "id = ?", whereArgs: [user.id]);
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
        'users',
        user.toMapWithoutId(),
        where: "id = ?",
        whereArgs: [user.id],
      );
      print("Usuarios actualizado: ${user.name}");
      return true;
    } catch (e) {
      print("Error al actualizar a los usuarios: $e");
      return false;
    }
  }

  static Future<bool> validateUserLogin(
      String Username, String password) async {
    try {
      sqflite.Database db = await _openDB();
      //Obtener la lista de usuarios

      final List<Map<String, dynamic>> UserList = await db.query(
        "users",
        where: "name = ? AND password =?",
        whereArgs: [Username, password],
      );
      final List<Map<String, dynamic>> test = await db.query("users");
      test.forEach((element) { print('Elemento: $element'); });

      if (UserList.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<List<User>> getUser() async {
    try {
      sqflite.Database db = await _openDB();
      final List<Map<String, dynamic>> userList = await db.query("users");
      return List.generate(
        userList.length,
            (i) => User(
          id: userList[i]["id"],
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
