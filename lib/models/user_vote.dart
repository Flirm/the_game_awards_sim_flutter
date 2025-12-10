class UserVote {
  int? id;
  int? userId;
  int? categoryId;
  int? voteGameId;

  UserVote(this.id, this.userId, this.categoryId, this.voteGameId);

  UserVote.fromMap(Map map) {
    id = map['id'];
    userId = map['user_id'];
    categoryId = map['category_id'];
    voteGameId = map['vote_game_id'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'user_id': userId,
      'category_id': categoryId,
      'vote_game_id': voteGameId
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}