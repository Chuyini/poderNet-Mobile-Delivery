import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as sqlite;

class BaseDataHelper {
  Future<Database> _openDataBase() async {
    final dataBasePath = await getDatabasesPath();
    final path = sqlite.join(dataBasePath, 'myDataBase.db');
    return openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE delivery (id INTEGER PRIMARY KEY, nombre TEXT, fecha TEXT, contrato TEXT)', // Cambié 'DATE' a 'TEXT' para facilitar el manejo
        );
      },
      version: 1,
    );
  }

  Future<void> addDataBase() async {
    final dataBase = await _openDataBase();
    await dataBase.insert(
      'delivery',
      {
        'nombre': 'Id Prueba',
        'fecha': '2024-01-11', // Asegúrate de proporcionar un valor de fecha válido
        'contrato': 'Empresarial'
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Agregado a la base de datos");
    await dataBase.close();
  }

  Future<void> getDataFromDataBase() async {
    final dataBase = await _openDataBase();
    final data = await dataBase.query("delivery");
    print("Datos de la tabla:");
    print(data);
    await dataBase.close();
  }
}
