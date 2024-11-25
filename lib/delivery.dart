class Delivery {
  late String name;
  late String contract;

  final int? id;
  late String date;

  late String ip;

  late String mask;
  late String gw;

  late String dns;
  late String radioBase;

  late String routerScreenshot;
  late String speedtestScreenshot;

  late String coordinates;

  late int idCompany;

  String photos = "Vacio";

  Delivery(
      {this.id,
        required this.name,
        required this.contract,
        required this.date,
        required this.coordinates,
        required this.gw,
        required this.mask,
        required this.ip,
        required this.dns,
        required this.radioBase,
        required this.routerScreenshot,
        required this.speedtestScreenshot,
        required this.idCompany,
        required this.photos});

//Funcion que transforma a json o Map

  Map<String, dynamic> toMap() {
    return {
      'id':id,
      'name': name,
      'contract': contract,
      'date': date,
      'coordinates': coordinates,
      'ip': ip,
      'gw': gw,
      'mask': mask,
      'dns': dns,
      'radioBase': radioBase,
      'routerScreenshot': routerScreenshot,
      'speedtestScreenshot': speedtestScreenshot,
      'idCompany': idCompany,
      'photos': photos
    };
  }
}
