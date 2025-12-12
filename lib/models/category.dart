class Category {
  int? id;
  int? userId;
  String? title;
  String? description;
  String? startDate;
  String? endDate;

  Category(this.id, this.userId, this.title, this.description, this.startDate, this.endDate);

  Category.fromMap(Map map){
    id = map['id'];
    userId = map['user_id'];
    title = map['title'];
    description = map['description'];
    startDate = map['start_date'];
    endDate = map['end_date'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate,
      'end_date': endDate
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}