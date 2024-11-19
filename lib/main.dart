import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'db.dart';
import 'delivery.dart';

void main() {
  runApp(
    MaterialApp(
      home: ViewList(),
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Entregas"),
        ),
      ),
      body: _screens[_selectedIndex], // Mostrar la pantalla seleccionada.
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Casa"),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "Noticias"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap, // Actualizar el índice seleccionado.
      ),
      floatingActionButton: FloatingActionButton(
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
              builder: (context) => WorkingDelivery(_addNewDeliveryToDatabase,
                  length), //<- le pasamos la funcion de agregar al DataBase
            ),
          );
        }, // Añadir una nueva entrega.
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
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
              child: ListTile(
                leading: Icon(Icons.account_balance_sharp),
                title: Text(deliveryList[index]['name'] ?? ''),
                // Mostrar el nombre de la entrega.
                subtitle: Text('Fecha: ${deliveryList[index]['date']}'),
                // Mostrar la fecha de la entrega.
                trailing: Text(
                    'Contrato: ${deliveryList[index]['contract']}'), // Mostrar el contrato de la entrega.
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
  Function deleteDataBase;

  Principal(this.deleteDataBase);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text("Pantalla de noticias"),
        ),
        ElevatedButton(
            onPressed: () {
              deleteDataBase();
            },
            child: Text("Eliminar base de datos"))
      ],
    );
  }
}

class OneDeliveryScreen extends StatefulWidget {
  late Map<String, dynamic> delivery;
  final Function deleteDelivery;
  final Function upDateDB;

  OneDeliveryScreen(
      {required this.delivery,
      required this.deleteDelivery,
      required this.upDateDB});

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
        id: delivery['id']));
    /*DB.deleteDelivery(); */
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
        id: delivery['id']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Entregas"),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Center(
                child: Text(
                  "${delivery['name']}",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: Text("${delivery['contract']}"),
          ),
          Center(
            child: Text("${delivery['date']}"),
          ),
          Center(
            child: Text("${delivery['ip']}"),
          ),
          Center(
            child: Text("${delivery['gw']}"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: TextButton(
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
                  child: Text("Editar"),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                child: TextButton(
                  onPressed: () {
                    deleteDelivery();
                    Navigator.pop(context, true);
                  },
                  child: Text("Borrar"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ScreenTests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: SizedBox(
        width: 450,
        child: TextField(
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'nombre',
          ),
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
        contract: contract, // Usamos la variable contract calculada arriba
        date: "2020-11-12", // ajustando
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
        title: Text(isUpdate ? "Actualizar entrega" : "Nueva entrega"),
        backgroundColor: Colors.indigo,
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
                if (isUpdate) {
                  _updateN(widget.delivery!);

                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  _saveData();
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
