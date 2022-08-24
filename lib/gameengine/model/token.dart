import 'package:ludo/gameengine/model/user_model.dart';

import './position.dart';

enum TokenType { green, yellow, blue, red }

enum TokenState { initial, home, normal, safe, safeinpair, arrived }

class Token {
  final int id;
  final TokenType type;
  Position tokenPosition;
  TokenState tokenState;
  int positionInPath;
  final int turn;
  UserModel userModel;

  Token(this.type, this.tokenPosition, this.tokenState, this.id, this.turn,
      {this.userModel, this.positionInPath});
}
