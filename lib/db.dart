import 'delivery.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sqflite;

class DB {
  static final DB _instance = DB._internal();
  static sqflite.Database? _database;

  // Constructor privado
  DB._internal();

  // Instancia única de la clase DB
  factory DB() {
    return _instance;
  }

  // Inicializa la base de datos
  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Crear y configurar
  Future<sqflite.Database> _initDB() async {
    final dbPath = await sqflite.getDatabasesPath();
    return await sqflite.openDatabase(
      path.join(dbPath, 'deliveries.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE deliveries(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            name TEXT,
            contract TEXT,
            date TEXT,
            coordinates TEXT,
            gw TEXT,
            mask TEXT,
            ip TEXT,
            dns TEXT,
            radioBase TEXT,
            routerScreenshot TEXT,
            speedtestScreenshot TEXT,
            photos TEXT,
            idCompany INTEGER
          )
        ''');
      },
    );
  }

  static Future<sqflite.Database> _openDB() async {
    return sqflite.openDatabase(
      path.join(await sqflite.getDatabasesPath(), 'delivery.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE delivery (id INTEGER PRIMARY KEY AUTOINCREMENT, idCompany INTEGER, name TEXT, contract TEXT, date DATE, ip TEXT, mask TEXT, gw TEXT, dns TEXT, radioBase TEXT, routerScreenshot TEXT, speedtestScreenshot TEXT, coordinates TEXT, photos TEXT);');
      },
      version: 1,
    );
  }

  static Future<void> deleteDatabase() async {
    try {
      String dbPath =
      path.join(await sqflite.getDatabasesPath(), 'delivery.db');
      await sqflite.deleteDatabase(dbPath);
    } catch (e) {
      print(e);
    }
  }

  static Future<bool> insertDelivery(Delivery delivery) async {
    try {
      sqflite.Database db = await _openDB();
      // Mapear
      final data = delivery.toMap();

      // Imprimir los datos del mapa de la entrega
      print("\n La data del mapa es: $data\n");

      await db.insert("delivery", data);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> deleteDelivery(Delivery delivery) async {
    try {
      sqflite.Database db = await _openDB();
      await db.delete("delivery", where: "id = ?", whereArgs: [delivery.id]);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> updateDelivery(Delivery delivery) async {
    try {
      sqflite.Database db = await _openDB();
      print("Delivery actual: ${delivery.idCompany}");
      await db.update(
        'delivery',
        delivery.toMap(),
        where: "id = ?",
        whereArgs: [delivery.id],
      );

      return true;
    } catch (e) {
      print("Error al actualizar el delivery: $e");
      return false;
    }
  }

  static Future<List<Delivery>> getDeliveries() async {
    try {
      sqflite.Database db = await _openDB();
      final List<Map<String, dynamic>> deliveriesList =
      await db.query("delivery");
      return List.generate(
        deliveriesList.length,
            (i) => Delivery(
          id: deliveriesList[i]["id"],
          idCompany: deliveriesList[i]["idCompany"] ?? 0,
          name: deliveriesList[i]["name"] ?? '',
          contract: deliveriesList[i]["contract"] ?? '',
          date: deliveriesList[i]["date"] ?? '',
          coordinates: deliveriesList[i]["coordinates"] ?? '',
          ip: deliveriesList[i]["ip"] ?? '',
          mask: deliveriesList[i]["mask"] ?? '',
          gw: deliveriesList[i]["gw"] ?? '',
          dns: deliveriesList[i]["dns"] ?? '',
          radioBase: deliveriesList[i]["radioBase"] ?? '',
          routerScreenshot: deliveriesList[i]["routerScreenshot"] ?? '',
          speedtestScreenshot: deliveriesList[i]["speedtestScreenshot"] ?? '',
          photos: deliveriesList[i]["photos"] ?? '',
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
  Delivery delivery = Delivery(
    idCompany: 23,
    name: "Farmacias",
    contract: "Empresarial",
    date: "2020-11-12",
    ip: "192.168.0.5",
    mask: "255.255.255.0",
    gw: "192.168.0.2",
    dns: "8.8.8.8",
    radioBase: "MAGONZA",
    routerScreenshot: "Vacio",
    speedtestScreenshot: "Vacio",
    coordinates: "Vacio",
    photos: "Vacio",
  );

  // Insertar la entrega en la base de datos
  bool success = await DB.insertDelivery(delivery);

  if (success) {
    print("Entrega insertada exitosamente.");
  } else {
    print("Error al insertar la entrega.");
  }

  // Obtener todas las entregas
  List<Delivery> deliveries = await DB.getDeliveries();
  deliveries.forEach((delivery) {
    print(delivery.toMap());
  });
}
