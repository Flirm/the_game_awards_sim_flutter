class User {
  int? id;
  String? name;
  String? email;
  String? password;
  int? role;

  User(this.id, this.name, this.email, this.password, this.role);

  User.fromMap(Map map) {
    id = map['id']; 
    name = map['name'];
    email = map['email']; 
    password = map['password']; 
    role = map['role'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'name': name,
      'email': email,
      'password': password,
      'role': role
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}