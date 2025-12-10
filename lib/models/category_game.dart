class CategoryGame {
  int? id;
  int? categoryId;
  int? gameId;

  CategoryGame(this.id, this.categoryId, this.gameId);

  CategoryGame.fromMap(Map map) {
    id = map['id'];
    categoryId = map['category_id'];
    gameId = map['game_id'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'category_id': categoryId,
      'game_id': gameId
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}