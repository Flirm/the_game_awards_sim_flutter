class Category {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? date;

  Category(this.id, this.userId, this.title, this.description, this.date);

  Category.fromMap(Map map){
    id = map['id'];
    userId = map['user_id'];
    title = map['title'];
    description = map['description'];
    date = map['date'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'user_id': userId,
      'title': title,
      'description': description,
      'date': date
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}