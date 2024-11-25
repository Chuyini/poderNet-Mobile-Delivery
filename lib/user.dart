class User {

  late final String name;
  final int? id;
  late final String password;


  User({required this.name, required this.password, this.id});


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return { 'name': name, 'password': password,};
  }



}