class GameGenre {
  int? gameId;
  int? genreId;

  GameGenre(this.gameId, this.genreId);

  GameGenre.fromMap(Map map) {
    gameId = map['game_id'];
    genreId = map['genre_id'];
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'game_id': gameId,
      'genre_id': genreId
    };

    return map;
  }
}
