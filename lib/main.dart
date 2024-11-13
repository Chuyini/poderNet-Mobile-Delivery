import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Entregas"),
        ),
      ),
      body: DeliveryList(),
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
      "Fecha": "20/01/2024",
      "Nombre": "0982- MANUEL DOBLADO ID 196 CVE CLMD - CELAYA",
      "Contrato": "Empresarial"
    },
    {
      "Fecha": "20/01/2024",
      "Nombre": "0982- MANUEL DOBLADO ID 196 CVE CLMD - CELAYA",
      "Contrato": "Empresarial"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
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
        });
  }
}
