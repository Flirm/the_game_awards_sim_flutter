import 'package:the_game_awards_sim_flutter/models/genre.dart';

class Game {
  int? id;
  int? userId;
  String? name;
  String? description;
  String? releaseDate;

  List<Genre> genres;

  Game({this.id, this.userId, this.name, this.description, this.releaseDate, this.genres = const []});

  factory Game.fromMap(Map map) {
    return Game(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      description: map['description'],
      releaseDate: map['release_date'],
      genres: [],
    );
  }

  Map<String, dynamic> toMap(){ 
    Map<String, dynamic> map = {
      'user_id': userId, 
      'name': name,
      'description': description, 
      'release_date': releaseDate
    };

    if (id != null) {
      map["id"] = id;
    }

    return map;
  }
}