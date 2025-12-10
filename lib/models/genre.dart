import 'package:the_game_awards_sim_flutter/models/game.dart';

class Genre {
  int? id;
  String? name;

  List<Game> games;

  Genre({this.id, this.name, this.games = const []});

  factory Genre.fromMap(Map map){
    return Genre(
      id: map['id'],
      name: map['name'],
      games: [],
    );
  }

  Map<String, dynamic> toMap(){ 
    Map<String, dynamic> map = {
      'name': name,
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}