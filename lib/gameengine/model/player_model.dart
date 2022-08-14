import 'package:ludo/gameengine/model/token.dart';

class Player {
  final int id;
  final String playerName;
  final TokenType tokenType;

  Player({this.id, this.playerName, this.tokenType});
}
