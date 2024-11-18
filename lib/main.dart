//import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:flutter/material.dart';
import 'baseData_helper.dart'
    as helperDataBase; //<-- importamos las base de datos

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
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewListState();
  }
}

class _ViewListState extends State<ViewList> {
  final dataBase = helperDataBase.BaseDataHelper();

  int _selectedIndex = 0;
  List<Widget> _screen = [
    DeliveryList(),
    Principal(),
  ];

  void _onItemTap(int index) {
    //agarramos ese index del navBar bottom

    setState(() {
      _selectedIndex = index; //se loa asignamos a selectedIndex
    });
  }

  void _addNewDeliveryToDataBase() async {
    //await dataBase.addDataBase();
    await dataBase.getDataFromDataBase();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Entregas"),
        ),
      ),
      body: _screen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Casa"),
          BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: "Casa"),
        ],
        currentIndex: _selectedIndex,
        //<-- aqqui decimos en que indice esta y lo cambiamos con un setstate
        onTap: (index) {
          _onItemTap(index);
        }, //<-- aqui el index o cualquier variable es el numero indice de la lista de iconos o del app bar
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewDeliveryToDataBase();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

class DeliveryList extends StatelessWidget {
  List<Map<String, String>> _delivery = [
    {
      "Fecha": "20/01/2024",
      "Nombre": "0982- MANUEL DOBLADO ID 196 CVE CLMD - CELAYA",
      "Contrato": "Empresarial"
    },
    {
      "Fecha": "21/01/2024",
      "Nombre": "0782- JUAN PÉREZ ID 200 CVE CLJP - QUERÉTARO",
      "Contrato": "Residencial"
    },
    {
      "Fecha": "22/01/2024",
      "Nombre": "0563- ANA MARTÍNEZ ID 210 CVE CLAM - SAN LUIS POTOSÍ",
      "Contrato": "Industrial"
    },
    {
      "Fecha": "23/01/2024",
      "Nombre": "0456- LUIS HERNÁNDEZ ID 215 CVE CLHL - GUANAJUATO",
      "Contrato": "Empresarial"
    },
    {
      "Fecha": "24/01/2024",
      "Nombre": "0234- MARÍA GARCÍA ID 220 CVE CLMG - LEÓN",
      "Contrato": "Residencial"
    },
    {
      "Fecha": "25/01/2024",
      "Nombre": "0198- PEDRO LÓPEZ ID 225 CVE CLPL - AGUASCALIENTES",
      "Contrato": "Industrial"
    }
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: ListView.builder(
          itemCount: _delivery.length,
          itemBuilder: (context, index) {
            return InkWell(
              child: Center(
                child: ListTile(
                  leading: Icon(Icons.account_balance_sharp),
                  title: Text(_delivery[index]['Nombre'] ?? ''),
                  subtitle: Text('Fecha: ${_delivery[index]['Fecha']}'),
                  trailing: Text('Contrato: ${_delivery[index]['Contrato']}'),
                ),
              ),
              onTap: () {}, // Acción al hacer clic },
            );
          }),
    );
  }
}

class Principal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        Center(
          child: Text("Pantalla de noticias"),
        ),
      ],
    );
  }
}
