import 'dart:io';
import 'package:flutter/material.dart';
import 'package:podernet4/dbUserS.dart';
import 'db.dart';
import 'delivery.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'user.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MaterialApp(
      home: LoginScreen(),
      title: "Vista Entregas",
    ),
  );
}

class ViewList extends StatefulWidget {
  @override
  _ViewListState createState() => _ViewListState();
}

class _ViewListState extends State<ViewList> {
  int _selectedIndex = 0;

  // Lista de entregas almacenadas en la base de datos.
  List<Map<String, dynamic>> _deliveryList = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveries(); // Cargar entregas al inicio.
  }

  //Eliminar de la base de datos una entrega
  void deleteDelivery(Delivery delivery) async {
    await DB.deleteDelivery(delivery);
    _loadDeliveries();
  }

  // Método para cargar entregas desde la base de datos.
  void _loadDeliveries() async {
    List<Delivery> deliveries = await DB.getDeliveries();
    setState(() {
      _deliveryList = deliveries.map((delivery) => delivery.toMap()).toList();
    });
  }

  //Método para actualizar el índice seleccionado del BottomNavigationBar.
  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //Método para añadir una nueva entrega a la base de datos.
  void _addNewDeliveryToDatabase(Delivery delivery) async {
    await DB.insertDelivery(delivery);
    _loadDeliveries(); // Recargar datos después de añadir una nueva entrega.
  }

  //elimiar base de datos
  Future<void> deletDataBase() async {
    await DB.deleteDatabase();
    _loadDeliveries();
  }

//Metdor para obtener el tamaño de la base datos

  Future<int> getLengthDataBase() async {
    List<Delivery> deliveries = await DB.getDeliveries();
    return deliveries.length;
  }

  //Aqui actualizamos la base de datos

  Future<void> updateDB(Delivery delivery) async {
    await DB.updateDelivery(delivery);
    print("\nAqui se debe actualizar \n");
    print('id: ${delivery.id}');
    print('name: ${delivery.name}');
    print('contract: ${delivery.contract}');
    print('date: ${delivery.date}');
    print('coordinates: ${delivery.coordinates}');
    print('gw: ${delivery.gw}');
    print('mask: ${delivery.mask}');
    print('ip: ${delivery.ip}');
    print('dns: ${delivery.dns}');
    print('radioBase: ${delivery.radioBase}');
    print('routerScreenshot: ${delivery.routerScreenshot}');
    print('speedtestScreenshot: ${delivery.speedtestScreenshot}');
    print('idCompany: ${delivery.idCompany}');
    print('photos: ${delivery.photos}');
    _loadDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    // Definir las pantallas, pasando la lista de entregas como argumento.
    List<Widget> _screens = [
      DeliveryList(
        deliveryList: _deliveryList,
        deleteDelivery: deleteDelivery,
        updateDelivery: updateDB,
      ),
      // Se pasa _deliveryList a DeliveryList
      Principal(deletDataBase),
      ApiPrtgScreen(deliveryList: _deliveryList),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Entregas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Color del texto
          ),
        ),
        centerTitle: true, // Centrar el título
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.black45], // Degradado de fondo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('imagenes/poderNet.jpg'), // Imagen de fondo
              fit: BoxFit.cover,
              opacity: 0.2, // Ajustar opacidad para combinar con el degradado
            ),
          ),
        ),
      ),
      body: _screens[_selectedIndex], // Mostrar la pantalla seleccionada.
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Entregas"),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "Eliminar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_outlined), label: "PRTG API"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
        // Actualizar el índice seleccionado.
        unselectedItemColor: Colors.black54,
        selectedItemColor: Colors.blueAccent,
      ),

      floatingActionButton: _selectedIndex != 2 && _selectedIndex != 1
          ? FloatingActionButton(
              onPressed: () async {
                int length;
                try {
                  length = await getLengthDataBase();
                } catch (e) {
                  length = 0;
                  print("No se pudo saber el tamaño seguro es 0");
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkingDelivery(
                        _addNewDeliveryToDatabase,
                        length), //<- le pasamos la funcion de agregar al DataBase
                  ),
                );
              }, // Añadir una nueva entrega.
              child: Icon(Icons.add),
              backgroundColor: Colors.indigo,
            )
          : null,
    );
  }
}

class DeliveryList extends StatelessWidget {
  late List<Map<String, dynamic>> deliveryList;
  final Function updateDelivery;

  final Function deleteDelivery;

  // Constructor para recibir la lista de entregas como argumento.
  DeliveryList(
      {required this.deliveryList,
      required this.deleteDelivery,
      required this.updateDelivery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView.builder(
        itemCount: deliveryList.length, // Longitud de la lista de entregas.
        itemBuilder: (context, index) {
          return InkWell(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                child: ListTile(
                  leading: Icon(Icons.account_balance_sharp),
                  title: Text(deliveryList[index]['name'] ?? ''),
                  // Mostrar el nombre de la entrega.
                  subtitle: Text('Fecha: ${deliveryList[index]['date']}'),
                  // Mostrar la fecha de la entrega.
                  trailing: Text(
                      'Contrato: ${deliveryList[index]['contract']}'), // Mostrar el contrato de la entrega.
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          offset: Offset(4, 4)),
                    ]),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OneDeliveryScreen(
                    delivery: deliveryList[index],
                    deleteDelivery: deleteDelivery,
                    upDateDB: updateDelivery,
                  ),
                ),
              );
              print("Presionamos delivery id:${deliveryList[index]['id']}  ");
            }, // Acción al hacer clic.
          );
        },
      ),
    );
  }
}

class Principal extends StatelessWidget {
  final Function deleteDataBase;

  Principal(this.deleteDataBase);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Pantalla de Formateo",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
            SizedBox(height: 40), // Espaciado entre texto y botón
            ElevatedButton(
              onPressed: () {
                deleteDataBase();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                backgroundColor: Colors.red, // Color del fondo del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5, // Sombra del botón
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.delete, color: Colors.white), // Icono de borrar
                  SizedBox(width: 10), // Espaciado entre ícono y texto
                  Text(
                    "Eliminar base de datos local",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color del texto
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OneDeliveryScreen extends StatefulWidget {
  late Map<String, dynamic> delivery;
  final Function deleteDelivery;
  final Function upDateDB;

  OneDeliveryScreen({
    required this.delivery,
    required this.deleteDelivery,
    required this.upDateDB,
  });

  @override
  State<StatefulWidget> createState() {
    return _OneDeliveryScreenState();
  }
}

class _OneDeliveryScreenState extends State<OneDeliveryScreen> {
  late Map<String, dynamic> delivery = widget.delivery;

  void deleteDelivery() async {
    print("Eliminar id ${delivery['id']}");
    await widget.deleteDelivery(Delivery(
      name: delivery['name'],
      contract: delivery['contract'],
      date: delivery['date'],
      coordinates: delivery['coordinates'],
      gw: delivery['gw'],
      mask: delivery['mask'],
      ip: delivery['ip'],
      dns: delivery['dns'],
      radioBase: delivery['radioBase'],
      routerScreenshot: delivery['routerScreenshot'],
      speedtestScreenshot: delivery['speedtestScreenshot'],
      idCompany: delivery['idCompany'],
      photos: delivery['photos'],
      id: delivery['id'],
    ));
  }

  void updateDelivery(Delivery delivery) async {
    await widget.upDateDB(delivery);
  }

  Delivery deliveryToDelivery(Map<String, dynamic> delivery) {
    return Delivery(
      name: delivery['name'],
      contract: delivery['contract'],
      date: delivery['date'],
      coordinates: delivery['coordinates'],
      gw: delivery['gw'],
      mask: delivery['mask'],
      ip: delivery['ip'],
      dns: delivery['dns'],
      radioBase: delivery['radioBase'],
      routerScreenshot: delivery['routerScreenshot'],
      speedtestScreenshot: delivery['speedtestScreenshot'],
      idCompany: delivery['idCompany'],
      photos: delivery['photos'],
      id: delivery['id'],
    );
  }

  Map<String, dynamic> deliveryToMap(Delivery delivery) {
    return {
      'id': delivery.id,
      'name': delivery.name,
      'contract': delivery.contract,
      'date': delivery.date,
      'coordinates': delivery.coordinates,
      'gw': delivery.gw,
      'mask': delivery.mask,
      'ip': delivery.ip,
      'dns': delivery.dns,
      'radioBase': delivery.radioBase,
      'routerScreenshot': delivery.routerScreenshot,
      'speedtestScreenshot': delivery.speedtestScreenshot,
      'idCompany': delivery.idCompany,
      'photos': delivery.photos,
    };
  }

  void emptyFunction() {
    print("\nAQUI SE ACTUALIZA\n");
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50], // Fondo azul claro
          borderRadius: BorderRadius.circular(10), // Bordes redondeados
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // Sombra
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue, // Fondo del ícono
            child: Icon(
              icon,
              color: Colors.white, // Color del ícono
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black54, // Color del título
            ),
          ),
          subtitle: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black, // Color del valor
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalles de Entrega",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Color del texto
          ),
        ),
        centerTitle: true, // Centrar el título
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.black12], // Degradado de fondo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('imagenes/poderNet.jpg'), // Imagen de fondo
              fit: BoxFit.cover,
              opacity: 0.3, // Ajustar opacidad
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20), // Espaciado inicial
            Text(
              "${delivery['name']}",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo, // Tono destacado para el nombre
              ),
            ),
            SizedBox(height: 15), // Espaciado entre widgets
            _buildInfoCard(
                "Contrato", "${delivery['contract']}", Icons.assignment),
            _buildInfoCard(
                "Fecha", "${delivery['date']}", Icons.calendar_today),
            _buildInfoCard("Dirección IP", "${delivery['ip']}", Icons.router),
            _buildInfoCard(
                "Puerta de Enlace", "${delivery['gw']}", Icons.network_check),
            _buildInfoCard(
                "Coordenadas", "${delivery['coordinates']}", Icons.location_on),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Color de fondo
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Delivery deliveryD = deliveryToDelivery(delivery);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkingDelivery(
                          emptyFunction,
                          0,
                          delivery: deliveryD,
                          updateDelivery: updateDelivery,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Editar",
                    style: TextStyle(
                      color: Colors.white, // Color del texto
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color de fondo
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    deleteDelivery();
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    "Borrar",
                    style: TextStyle(
                      color: Colors.white, // Color del texto
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Espaciado final
          ],
        ),
      ),
    );
  }
}

class WorkingDelivery extends StatefulWidget {
  final Function addDataBase;
  final Delivery? delivery;
  final Function? updateDelivery;
  final dynamic length;

  WorkingDelivery(this.addDataBase, this.length,
      {this.delivery, this.updateDelivery});

  @override
  _WorkingDeliveryState createState() => _WorkingDeliveryState();
}

class _WorkingDeliveryState extends State<WorkingDelivery> {
  final GlobalKey<_RadioState> _childKey = GlobalKey<_RadioState>();

  // Controladores de texto
  late TextEditingController _ipController;
  late TextEditingController _maskController;
  late TextEditingController _gwController;
  late TextEditingController _dnsController;
  late TextEditingController _radioBaseController;
  late TextEditingController _coordinatesController;
  late TextEditingController _nameController;

  // Variables para estado
  Delivery? delivery;
  late bool isUpdate;
  bool isCheckCompany = false;

  @override
  void initState() {
    super.initState();

    // Inicializar variables
    delivery = widget.delivery;
    isUpdate = delivery != null;
    if (delivery != null) {
      if (delivery!.contract.contains("Empresarial")) {
        isCheckCompany = true;
      } else {
        isCheckCompany = false;
      }
    } else {
      isCheckCompany = true;
    }

    // Inicializar controladores con valores existentes o por defecto
    _ipController = TextEditingController(text: isUpdate ? delivery?.ip : "");
    _maskController =
        TextEditingController(text: isUpdate ? delivery?.mask : "255.0.0.0");
    _gwController = TextEditingController(text: isUpdate ? delivery?.gw : "");
    _dnsController =
        TextEditingController(text: isUpdate ? delivery?.dns : "8.8.8.8");
    _radioBaseController =
        TextEditingController(text: isUpdate ? delivery?.radioBase : "");
    _coordinatesController =
        TextEditingController(text: isUpdate ? delivery?.coordinates : "");
    _nameController =
        TextEditingController(text: isUpdate ? delivery?.name : "");
  }

  @override
  void dispose() {
    // Liberar recursos de controladores
    _ipController.dispose();
    _maskController.dispose();
    _gwController.dispose();
    _dnsController.dispose();
    _radioBaseController.dispose();
    _coordinatesController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addDataBaseFromParent(Delivery delivery) {
    try {
      widget.addDataBase(delivery);
    } catch (e) {
      print("ERROR AL AÑADIR: $e");
    }
  }

  void _saveData() {
    setState(() {
      // Determinar el valor del contrato basándonos en el estado del widget hijo
      String contract = _childKey.currentState?.isCheckedCompany == true
          ? "Empresarial"
          : "Residencial";

      // Crear objeto Delivery con los valores ingresados
      Delivery delivery = Delivery(
        name: _nameController.text,
        ip: _ipController.text,
        mask: _maskController.text,
        gw: _gwController.text,
        dns: _dnsController.text,
        radioBase: _radioBaseController.text,
        coordinates: _coordinatesController.text,
        contract: contract,
        // Usamos la variable contract calculada arriba
        date: "2020-11-12",
        // ajustando
        routerScreenshot: "Vacio",
        speedtestScreenshot: "Vacio",
        idCompany: 23,
        photos: "Vacio",
      );

      // Guardar datos mediante la función pasada al widget
      _addDataBaseFromParent(delivery);
    });

    // Volver a la pantalla anterior
    Navigator.pop(context);
  }

  void _updateN(Delivery deliverys) {
    setState(() {
      bool isCompany = _childKey.currentState?.isCheckedCompany ?? false;

      Delivery delivery = Delivery(
        id: deliverys.id,
        name: _nameController.text,
        ip: _ipController.text,
        mask: _maskController.text,
        gw: _gwController.text,
        dns: _dnsController.text,
        radioBase: _radioBaseController.text,
        coordinates: _coordinatesController.text,
        contract: isCompany ? "Empresarial" : "Residencial",
        date: "2020-11-12",
        // Ajusta esto según sea necesario
        routerScreenshot: "Vacio",
        speedtestScreenshot: "Vacio",
        idCompany: 23,
        photos: "Vacio",
      );
      widget.updateDelivery!(delivery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUpdate ? "Actualizar nueva entrega" : "Entregas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Color del texto
          ),
        ),
        centerTitle: true, // Centrar el título
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.black45], // Degradado de fondo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('imagenes/poderNet.jpg'), // Imagen de fondo
              fit: BoxFit.cover,
              opacity: 0.2, // Ajustar opacidad para combinar con el degradado
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Campo: Nombre de instalación
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Instalación",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo: IP
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: "IP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo: Mask
            TextField(
              controller: _maskController,
              decoration: InputDecoration(
                labelText: "MASK",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo: Gateway
            TextField(
              controller: _gwController,
              decoration: InputDecoration(
                labelText: "GW",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo: DNS
            TextField(
              controller: _dnsController,
              decoration: InputDecoration(
                labelText: "DNS",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo: Radio Base
            TextField(
              controller: _radioBaseController,
              decoration: InputDecoration(
                labelText: "Radio Base",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            // Campo: Coordenadas
            TextField(
              controller: _coordinatesController,
              decoration: InputDecoration(
                labelText: "Coordenadas",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),

            Radio(key: _childKey, focuseComany: isCheckCompany),
            //<-- usamos global keys para acceder a los valores del hijo
            // Botón Guardar
            ElevatedButton(
              onPressed: () {
                print("La instalacion es$_nameController ");
                if (_nameController.text == "" || _ipController.text == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Faltan campos, comprueba nombre e Ip'),
                      duration: Duration(seconds: 3),
                      // Tiempo antes de desaparecer
                      backgroundColor: Colors.orangeAccent,
                      // Color de fondo
                      behavior: SnackBarBehavior.floating,
                      // Flotante sobre la UI
                      margin: EdgeInsets.all(16),
                      // Margen para el diseño flotante
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Bordes redondeados
                      ),
                    ),
                  );
                } else {
                  if (isUpdate) {
                    _updateN(widget.delivery!);

                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    _saveData();
                  }
                }
              },
              child: Text("Guardar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }
}

class Radio extends StatefulWidget {
  bool? focuseComany;

  Radio({super.key, required this.focuseComany});

  @override
  State<StatefulWidget> createState() {
    return _RadioState();
  }
}

class _RadioState extends State<Radio> {
  bool isCheckedCompany = true;
  bool isCheckedResidential = false;

  @override
  void initState() {
    if (widget.focuseComany != null) {
      isCheckedCompany = widget.focuseComany!;
      isCheckedResidential = !widget.focuseComany!;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Transform.scale(
          scale: 1.5,
          child: Checkbox(
            value: isCheckedCompany,
            activeColor: Colors.lightBlue,
            onChanged: (vari) {
              setState(() {
                isCheckedCompany = vari!;
                isCheckedResidential = !isCheckedCompany;
              });
            },
          ),
        ),
        Text("Empresarial"),
        /*que pasara cuando presinamos*/

        Transform.scale(
          scale: 1.5,
          child: Checkbox(
              value: isCheckedResidential,
              activeColor: Colors.lightBlue,
              onChanged: (value) {
                setState(() {
                  isCheckedResidential = value!;
                  isCheckedCompany = !isCheckedResidential;
                });
              }),
        ),
        Text("Residencial"),
      ],
    );
  }
}

//APARTIR DE AQUI VAMOS A MANEJAR LO RELACIONADO A LA API DE PRTG

class ApiPrtgScreen extends StatefulWidget {
  final List<Map<String, dynamic>> deliveryList;

  ApiPrtgScreen({required this.deliveryList});

  @override
  State<StatefulWidget> createState() {
    return _ApiPrtgScreenState();
  }
}

class _ApiPrtgScreenState extends State<ApiPrtgScreen> {
  late final List<Map<String, dynamic>> deliveryList;
  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState(); // llamar a initState de la superclase primero

    // Hacemos una copia de la lista original
    var deliveryListAux = List<Map<String, dynamic>>.from(widget.deliveryList);

    // Filtramos la lista para excluir las entregas residenciales
    List<Map<String, dynamic>> filteredList = deliveryListAux
        .where((element) => element['contract'] != "Residencial")
        .toList();

    // Asignamos la lista filtrada
    setState(() {
      deliveryList = filteredList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: deliveryList.length,
          itemBuilder: (context, index) {
            final delivery = deliveryList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nombre: ${delivery['name'] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "IP: ${delivery['ip'] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Coordenadas: ${delivery['coordinates'] ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue[700],
                      ),
                    ),
                    delivery["idCompany"] != 1 && isButtonEnabled == true
                        ? ElevatedButton(
                            onPressed: () async {
                              Delivery device = Delivery(
                                  id: delivery['id'],
                                  name: delivery['name'],
                                  contract: delivery['contract'],
                                  date: delivery['date'],
                                  coordinates: delivery['coordinates'],
                                  gw: delivery['gw'],
                                  mask: delivery['mask'],
                                  ip: delivery['ip'],
                                  dns: delivery['dns'],
                                  radioBase: delivery['radioBase'],
                                  routerScreenshot:
                                      delivery['routerScreenshot'],
                                  speedtestScreenshot:
                                      delivery['speedtestScreenshot'],
                                  idCompany: 1,
                                  photos: delivery['photos']);
                              setState(() {
                                isButtonEnabled = false;
                              });
                              if (await fetchData(device)) {
                                setState(() {
                                  showAlertDialog(context);
                                  deliveryList[index]['idCompany'] = 1;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('¡Registro con exito!'),
                                    duration: Duration(seconds: 1),
                                    // Tiempo antes de desaparecer
                                    backgroundColor: Colors.green,
                                    // Color de fondo
                                    behavior: SnackBarBehavior.floating,
                                    // Flotante sobre la UI
                                    margin: EdgeInsets.all(16),
                                    // Margen para el diseño flotante
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // Bordes redondeados
                                    ),
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('¡Registro con exito!'),
                                    duration: Duration(seconds: 1),
                                    // Tiempo antes de desaparecer
                                    backgroundColor: Colors.green,
                                    // Color de fondo
                                    behavior: SnackBarBehavior.floating,
                                    // Flotante sobre la UI
                                    margin: EdgeInsets.all(16),
                                    // Margen para el diseño flotante
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          12), // Bordes redondeados
                                    ),
                                  ),
                                );
                              } else {
                                setState(() {
                                  isButtonEnabled = true;
                                });
                              }
                            },
                            child: Text("Subir a PRTG"),
                          )
                        : Text(
                            "Subido",
                            style:
                                TextStyle(color: Colors.green, fontSize: 10.00),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text("PRTG"),
      content: Text("Se ha subido con Exito"),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

int fixStorage(int number){
  var auxNumber = 3;
  number = number + 2;
  auxNumber = auxNumber+number;
  return number;
}

Future<bool> fetchData(Delivery device) async {
  ///api/duplicateobject.htm?id=id_del_dispositivo_a_clonar&name=nuevo_nombre&host=nuevo_nombre_de_host_o_ip&targetid=id_del_grupo_destino
  String grpuID = '5171'; //<--Grupo Movil
  String masterDevice = '5172';
  String name = device.name ?? "DISPOSITIVO SIN NOMBRE";
  String ip = device.ip ?? '0.0.0.0';

  //llamada a la bases de datos update
  await DB.updateDelivery(device);

  var url = Uri.parse(
      'http://elpoderdeinternet.mx:8045/api/duplicateobject.htm?id=$masterDevice&name=$name&host=$ip&targetid=$grpuID&apitoken=5MVP647FU4GJG67Z32KOP7PKAMY57AOD2AHYMJRIWQ======');
  try {

    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 10));
    if (response.statusCode == 200) {
      print('Datos obtenidos exitosamente:');
      return true;
    } else {
      print('Error al obtener datos. Código de estado: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Ocurrió un error: $e');
    return false;
  }
}

void fetchDataWhitoutClone() async {
  ///api/duplicateobject.htm?id=id_del_dispositivo_a_clonar&name=nuevo_nombre&host=nuevo_nombre_de_host_o_ip&targetid=id_del_grupo_destino
  String grpuID = '5171'; //<--Grupo Movil
  String masterDevice = '5172';

  var url = Uri.parse(
      'https://elpoderdeinternet.mx:8045/api/table.json?content=sensors&columns=sensor&apitoken=5MVP647FU4GJG67Z32KOP7PKAMY57AOD2AHYMJRIWQ======');
  try {
    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    ).timeout(Duration(seconds: 10));
    print('el parame$response.body');
    print("${response.headers['location']}");
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print('Datos obtenidos exitosamente: $data');
    } else {
      print('Error al obtener datos. Código de estado: ${response.statusCode}');
    }
  } catch (e) {
    print('Ocurrió un error: $e');
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class RegisterScreen extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void _addNewUsertoDatabase(User user) async {
    // Recargar datos después de añadir una nueva entrega.
    try {
      await DbUser.insertUser(user);
      print("Insertado con exito");
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Entregas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Color del texto
          ),
        ),
        centerTitle: true, // Centrar el título
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.black45], // Degradado de fondo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('imagenes/poderNet.jpg'), // Imagen de fondo
              fit: BoxFit.cover,
              opacity: 0.2, // Ajustar opacidad para combinar con el degradado
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación Lottie en la parte superior
              Lottie.asset(
                'animation/login2.json', // Ruta del archivo JSON
                height: 200,
              ),
              SizedBox(height: 24),
              // Campo de usuario
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.purple),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Campo de contraseña
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              // Campo de confirmación de contraseña
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              // Botón de registro
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue, // Fondo del botón
                ),
                onPressed: () async {
                  // Pausa de 3 segundos

                  try {
                    if (confirmPasswordController.text ==
                            passwordController.text &&
                        (passwordController.text != "" &&
                            userController.text != "")) {
                      User user = User(
                          name: userController.text,
                          password: passwordController.text);
                      _addNewUsertoDatabase(user);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('¡Registro con exito!'),
                          duration: Duration(seconds: 1),
                          // Tiempo antes de desaparecer
                          backgroundColor: Colors.green,
                          // Color de fondo
                          behavior: SnackBarBehavior.floating,
                          // Flotante sobre la UI
                          margin: EdgeInsets.all(16),
                          // Margen para el diseño flotante
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Bordes redondeados
                          ),
                        ),
                      );
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.pop(context);
                    } else {
                      throw Exception("Las contraseñas no coincen");
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Error al entrar!'),
                        duration: Duration(seconds: 3),
                        // Tiempo antes de desaparecer
                        backgroundColor: Colors.red,
                        // Color de fondo
                        behavior: SnackBarBehavior.floating,
                        // Flotante sobre la UI
                        margin: EdgeInsets.all(16),
                        // Margen para el diseño flotante
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bordes redondeados
                        ),
                      ),
                    );
                  }
                  ;
                  // Mostrar SnackBar usando ScaffoldMessenger.of(context)

                  print('Usuario: ${userController.text}');
                  print('Contraseña: ${passwordController.text}');
                  print(
                      'Confirmar Contraseña: ${confirmPasswordController.text}');
                },
                child: Text(
                  'Registrarse',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<bool> _isUser(String userName, String password) async {
    if (await DbUser.validateUserLogin(userName, password)) {
      print("Encontrado");
      return true;
    } else {
      print("No encintrado");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Entregas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // Color del texto
          ),
        ),
        centerTitle: true, // Centrar el título
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.black45], // Degradado de fondo
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            image: DecorationImage(
              image: AssetImage('imagenes/poderNet.jpg'), // Imagen de fondo
              fit: BoxFit.cover,
              opacity: 0.2, // Ajustar opacidad para combinar con el degradado
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation
              Lottie.asset(
                'animation/login2.json',
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 20),
              Text(
                '¡Bienvenido!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Por favor, ingresa tus credenciales para continuar.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              //SizedBox(height: 32),
              // Campo de usuario
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 16),
              // Campo de contraseña
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              // Botón de inicio de sesión
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  try {
                    if (await _isUser(
                                userController.text, passwordController.text) ==
                            true &&
                        (userController.text != "" &&
                            passwordController.text != "")) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewList(),
                        ),
                      );
                    } else {
                      throw Exception("Error no se encontro usuario");
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Error al entrar!'),
                        duration: Duration(seconds: 3),
                        // Tiempo antes de desaparecer
                        backgroundColor: Colors.red,
                        // Color de fondo
                        behavior: SnackBarBehavior.floating,
                        // Flotante sobre la UI
                        margin: EdgeInsets.all(16),
                        // Margen para el diseño flotante
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bordes redondeados
                        ),
                      ),
                    );
                  }
                  ;

                  print('Usuario: ${userController.text}');
                  print('Contraseña: ${passwordController.text}');
                },
                child: Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Opción de olvidar contraseña
              TextButton(
                onPressed: () async {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('¡Error al entrar!'),
                        duration: Duration(seconds: 3),
                        // Tiempo antes de desaparecer
                        backgroundColor: Colors.red,
                        // Color de fondo
                        behavior: SnackBarBehavior.floating,
                        // Flotante sobre la UI
                        margin: EdgeInsets.all(16),
                        // Margen para el diseño flotante
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Bordes redondeados
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Registrar',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
