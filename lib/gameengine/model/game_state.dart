import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ludo/game_home.dart';
import 'package:ludo/gameengine/model/dice_model.dart';
import 'package:ludo/gameengine/model/user_model.dart';
import 'package:ludo/gameengine/path.dart';

import './position.dart';
import './token.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameState with ChangeNotifier {
  Socket socket;
  DiceModel dice = DiceModel();
  List<Token> gameTokens = List<Token>(16);
  List<Position> starPositions;
  List<Position> greenInitital;
  List<Position> yellowInitital;
  List<Position> blueInitital;
  List<Position> redInitital;
  List<Map<String, dynamic>> arrivedTokens;
  List<String> winnersArray;
  int currentTurn;
  int numberOfTimesRolled; // applicaple when a 6 is rolled
  bool shouldPlay;
  bool currentPlayerHasPlayed = true;
  UserModel userModel;
  String currentPlayerId;
  // List<UserModel> users;
  // String? roomId;
  List<int> turns;
  int currentTurnIndex;

  final List<Map<String, dynamic>> tokens = [
    {"type": TokenType.green, "color": Colors.green},
    {"type": TokenType.yellow, "color": Colors.yellow},
    {"type": TokenType.blue, "color": Colors.blue},
    {"type": TokenType.red, "color": Colors.red}
  ];

  GameState() {
    gameTokens = [
      //Green Tokens home
      Token(TokenType.green, Position(2, 2), TokenState.initial, 0, 1),
      Token(TokenType.green, Position(2, 3), TokenState.initial, 1, 1),
      Token(TokenType.green, Position(3, 2), TokenState.initial, 2, 1),
      Token(TokenType.green, Position(3, 3), TokenState.initial, 3, 1),
      //Yellow Token
      Token(TokenType.yellow, Position(2, 11), TokenState.initial, 4, 2),
      Token(TokenType.yellow, Position(2, 12), TokenState.initial, 5, 2),
      Token(TokenType.yellow, Position(3, 11), TokenState.initial, 6, 2),
      Token(TokenType.yellow, Position(3, 12), TokenState.initial, 7, 2),
      // Blue Token
      Token(TokenType.blue, Position(11, 11), TokenState.initial, 8, 3),
      Token(TokenType.blue, Position(11, 12), TokenState.initial, 9, 3),
      Token(TokenType.blue, Position(12, 11), TokenState.initial, 10, 3),
      Token(TokenType.blue, Position(12, 12), TokenState.initial, 11, 3),
      // Red Token
      Token(TokenType.red, Position(11, 2), TokenState.initial, 12, 4),
      Token(TokenType.red, Position(11, 3), TokenState.initial, 13, 4),
      Token(TokenType.red, Position(12, 2), TokenState.initial, 14, 4),
      Token(TokenType.red, Position(12, 3), TokenState.initial, 15, 4),
    ];
    this.starPositions = [
      Position(6, 1),
      Position(2, 6),
      Position(1, 8),
      Position(6, 12),
      Position(8, 13),
      Position(12, 8),
      Position(13, 6),
      Position(8, 2)
    ];
    this.greenInitital = [];
    this.yellowInitital = [];
    this.blueInitital = [];
    this.redInitital = [];

    this.arrivedTokens = [];
    this.winnersArray = [];

    currentTurn = 1;
    numberOfTimesRolled = 0;
    shouldPlay = false;
    turns = [1, 2, 3, 4];
    currentTurnIndex = 0;

    // roomId =
    //     "${gameTokens?[0].userModel?.id}-${gameTokens?[4].userModel?.id}-${gameTokens?[8].userModel?.id}-${gameTokens?[12].userModel?.id}";
    initializeSocket();
    // dicerollSocket(dice);
  }

  Future<void> initializeSocket() async {
    socket =
        io("https://chat-socket-test-backend.herokuapp.com/", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect(); //connect the Socket.IO Client to the Server

    //SOCKET EVENTS
    // --> listening for connection
    socket.on('connect', (data) {
      Get.log("Socket Connected State ${socket.connected}");
    });

    //listen for when user joins game from the Server.
    socket.on('user_joined', (data) {
      Get.log("User Joined $data"); //
      // Get.snackbar("Chat", "${data['username']} Joined the Chat");
    });

    //listen for when Game State Changes.
    socket.on('game_state_changed', (data) {
      Get.log("Game State Changed $data"); //
      // isLoading.value = true;
      var decoded = json.decode(data);
      shouldPlay = decoded['should_play'];
      currentTurn = decoded['current_turn'];
      Get.log("Decoded Current Turn ${decoded['current_turn']}");
      numberOfTimesRolled = decoded['number_of_times_rolled'];
      currentTurnIndex = decoded['current_turn_index'];
      // turns = decoded['turns'];
      turns = List<int>.from(decoded['turns']);
      currentPlayerHasPlayed = decoded["currentPlayerHasPlayed"];
      // winnersArray = decoded["winnersArray"];
      // arrivedTokens = decoded["arrivedTokens"];
      notifyListeners();

      decodeSocketGameTokens(decoded['game_tokens']);
      decodeWinnersArrayAndArrivedTokensArray(
          decoded["winnersArray"], decoded["arrivedTokens"]);
      for (int i = 0; i < decoded['green_initial'].length; i++) {
        greenInitital[i] = Position(decoded['green_initial'][i]['row'],
            decoded['green_initial'][i]['column']);
      }
      for (int i = 0; i < decoded['red_initial'].length; i++) {
        redInitital[i] = Position(decoded['red_initial'][i]['row'],
            decoded['red_initial'][i]['column']);
      }
      for (int i = 0; i < decoded['yellow_initial'].length; i++) {
        yellowInitital[i] = Position(decoded['yellow_initial'][i]['row'],
            decoded['yellow_initial'][i]['column']);
      }
      for (int i = 0; i < decoded['blue_initial'].length; i++) {
        blueInitital[i] = Position(decoded['blue_initial'][i]['row'],
            decoded['blue_initial'][i]['column']);
      }
      for (int i = 0; i < decoded['star_positions'].length; i++) {
        starPositions[i] = Position(decoded['star_positions'][i]['row'],
            decoded['star_positions'][i]['column']);
      }
      notifyListeners();

      Get.log(" Turns ${decoded['turns']}");

      Get.log("Current socket turn ${decoded['current_turn']}");
      Get.log("Current socket should_play ${decoded['should_play']}");

      // isLoading.value = false;
    });

    socket.on('joined_game', (data) {
      var particularTokenIndex = tokens.indexWhere(
          (element) => element["type"].toString() == data["tokenType"]);
      Get.log("Data is $data");
      tokens[particularTokenIndex]["name"] = data["name"];
      notifyListeners();
    });

    socket.on('yourRound', (data) {
      Get.log("on Your Round Called");
      currentPlayerId = data["playerId"];
      Get.log("Your Round id $data");
      notifyListeners();
    });

    socket.on('missedOpportunity', (data) {
      updateCurrentTurnNew();
    });

    socket.on('pieceMovement', (data) {
      moveToken(decodeSingleGameToken(data['gameToken']), data['steps']);
    });

    socket.on('arrived', (data) {
      print(data);
    });

    socket.on('theFirstWinner', (data) {
      print(data);
    });

    socket.on('theSecondWinner', (data) {
      print(data);
    });

    socket.on('theThirdWinner', (data) {
      print(data);
    });

    socket.on('gameHasEnded', (data) {
      print(data);
    });

    // socket.on('dice_state_changed', (data) {
    //   print(data); //
    //   // isLoading.value = true;
    //   dice.diceOne = data['dice_number'];
    //   // dice.diceOneCount =

    //   print("Current socket Dice ${data['dice_number']}");
    //   print("Current assigned socket Dice ${dice.diceOne}");

    //   // isLoading.value = false;
    // notifyListeners();
    // });

    //listens when the client is disconnected from the Server
    socket.on('disconnect', (data) {
      Get.log('disconnect');
    });
  }

  emitPieceMovement(Token token, int steps) {
    if (currentPlayerId == userModel.id) {
      socket.emit('pieceMovement',
          {'gameToken': encodeGameToken(token), 'steps': steps});
    }
  }

  moveToken(Token token, int steps) {
    Position destination;
    int pathPosition;
    if (token.tokenState == TokenState.home) return;
    if (token.tokenState == TokenState.initial && steps != 6) return;
    if (token.tokenState == TokenState.initial && steps == 6) {
      destination = _getPosition(token.type, 0);
      pathPosition = 0;
      _updateInitalPositions(token);
      _updateBoardState(token, destination, pathPosition);
      this.gameTokens[token.id].tokenPosition = destination;
      this.gameTokens[token.id].positionInPath = pathPosition;
      notifyListeners();
      if (currentPlayerId == userModel.id) {
        if (steps == 6) {
          Get.log("From steps == 6 $steps");
          shouldPlay = true;
          updateGameStateToSocket();
          updateCurrentPlayerHasPlayed(true);
        } else if (steps != 6) {
          Get.log("From steps != 6 $steps");
          shouldPlay = false;
          updateCurrentTurnNew();
          updateCurrentPlayerHasPlayed(true);
        }
      }
    } else if (token.tokenState != TokenState.initial) {
      int step = token.positionInPath + steps;
      if (step >= 56) {
        var tokenIndex =
            arrivedTokens.indexWhere((element) => element["id"] == token.id);
        if (tokenIndex == -1) {
          arrivedTokens.add(encodeGameToken(token));
          var currentGameTokenIndex =
              this.gameTokens.indexWhere((element) => element.id == token.id);
          this.gameTokens[currentGameTokenIndex].tokenState =
              TokenState.arrived;
          notifyListeners();
          socket.emit('arrived', {"piece": encodeGameToken(token)});
        }
        var tokens = arrivedTokens
            .where((element) => element["type"] == token.type.toString());
        if (tokens.length == 4) {
          // 4 arrived
          var positionInWinnersArray = winnersArray
              .indexWhere((element) => element == token.type.toString());
          if (positionInWinnersArray == -1) {
            if (winnersArray.length == 0) {
              winnersArray.add(token.type.toString());
              turns.remove(token.turn);
              notifyListeners();
              socket.emit('theFirstWinner', {"playerId": token.userModel.id});
            } else if (winnersArray.length == 1) {
              winnersArray.add(token.type.toString());
              turns.remove(token.turn);
              notifyListeners();
              socket.emit('theSecondWinner', {"playerId": token.userModel.id});
            } else if (winnersArray.length == 2) {
              winnersArray.add(token.type.toString());
              turns.remove(token.turn);
              notifyListeners();
              socket.emit('theThirdWinner', {"playerId": token.userModel.id});
              socket.emit('gameHasEnded', {});
            }
          }
        }
      }
      if (step > 56) return;
      destination = _getPosition(token.type, step);
      pathPosition = step;
      var cutToken = _updateBoardState(token, destination, pathPosition);
      int duration = 0;
      for (int i = 1; i <= steps; i++) {
        duration = duration + 500;
        var future = new Future.delayed(Duration(milliseconds: duration), () {
          int stepLoc = token.positionInPath + 1;
          this.gameTokens[token.id].tokenPosition =
              _getPosition(token.type, stepLoc);
          this.gameTokens[token.id].positionInPath = stepLoc;
          token.positionInPath = stepLoc;
          notifyListeners();
        });
      }
      if (cutToken != null) {
        int cutSteps = cutToken.positionInPath;
        for (int i = 1; i <= cutSteps; i++) {
          duration = duration + 100;
          var future2 =
              new Future.delayed(Duration(milliseconds: duration), () {
            int stepLoc = cutToken.positionInPath - 1;
            this.gameTokens[cutToken.id].tokenPosition =
                _getPosition(cutToken.type, stepLoc);
            this.gameTokens[cutToken.id].positionInPath = stepLoc;
            cutToken.positionInPath = stepLoc;
            notifyListeners();
          });
        }
        var future2 = new Future.delayed(Duration(milliseconds: duration), () {
          _cutToken(cutToken);
          notifyListeners();
        });
      }
      if (currentPlayerId == userModel.id) {
        if (steps == 6) {
          Get.log("From steps == 6 $steps");
          shouldPlay = true;
          updateGameStateToSocket();
          updateCurrentPlayerHasPlayed(true);
        } else if (steps != 6) {
          Get.log("From steps != 6 $steps");
          shouldPlay = false;
          updateCurrentTurnNew();
          updateCurrentPlayerHasPlayed(true);
        }
      }
    } else if (token.tokenState != TokenState.initial && steps == 0) return;
  }

  Token _updateBoardState(Token token, Position destination, int pathPosition) {
    Token cutToken;
    //when the destination is on any star
    if (this.starPositions.contains(destination)) {
      this.gameTokens[token.id].tokenState = TokenState.safe;
      //this.gameTokens[token.id].tokenPosition = destination;
      //this.gameTokens[token.id].positionInPath = pathPosition;
      return null;
    }
    List<Token> tokenAtDestination = this.gameTokens.where((tkn) {
      if (tkn.tokenPosition == destination) {
        return true;
      }
      return false;
    }).toList();
    //if no one at the destination
    if (tokenAtDestination.length == 0) {
      this.gameTokens[token.id].tokenState = TokenState.normal;
      //this.gameTokens[token.id].tokenPosition = destination;
      //this.gameTokens[token.id].positionInPath = pathPosition;
      return null;
    }
    //check for same color at destination
    List<Token> tokenAtDestinationSameType = tokenAtDestination.where((tkn) {
      if (tkn.type == token.type) {
        return true;
      }
      return false;
    }).toList();

    if (tokenAtDestinationSameType.length == tokenAtDestination.length) {
      for (Token tkn in tokenAtDestinationSameType) {
        this.gameTokens[tkn.id].tokenState = TokenState.safeinpair;
      }
      this.gameTokens[token.id].tokenState = TokenState.safeinpair;
      //this.gameTokens[token.id].tokenPosition = destination;
      //this.gameTokens[token.id].positionInPath = pathPosition;
      return null;
    }

    if (tokenAtDestinationSameType.length < tokenAtDestination.length) {
      for (Token tkn in tokenAtDestination) {
        if (tkn.type != token.type && tkn.tokenState != TokenState.safeinpair) {
          //cut an unsafe token
          //_cutToken(tkn);
          cutToken = tkn;
        } else if (tkn.type == token.type) {
          this.gameTokens[tkn.id].tokenState = TokenState.safeinpair;
        }
      }
      //place token
      this.gameTokens[token.id].tokenState =
          tokenAtDestinationSameType.length > 0
              ? TokenState.safeinpair
              : TokenState.normal;
      // this.gameTokens[token.id].tokenPosition = destination;
      // this.gameTokens[token.id].positionInPath = pathPosition;
      return cutToken;
    }
  }

  _updateInitalPositions(Token token) {
    switch (token.type) {
      case TokenType.green:
        {
          this.greenInitital.add(token.tokenPosition);
        }
        break;
      case TokenType.yellow:
        {
          this.yellowInitital.add(token.tokenPosition);
        }
        break;
      case TokenType.blue:
        {
          this.blueInitital.add(token.tokenPosition);
        }
        break;
      case TokenType.red:
        {
          this.redInitital.add(token.tokenPosition);
        }
        break;
    }
  }

  _cutToken(Token token) {
    switch (token.type) {
      case TokenType.green:
        {
          this.gameTokens[token.id].tokenState = TokenState.initial;
          this.gameTokens[token.id].tokenPosition = this.greenInitital.first;
          this.greenInitital.removeAt(0);
        }
        break;
      case TokenType.yellow:
        {
          this.gameTokens[token.id].tokenState = TokenState.initial;
          this.gameTokens[token.id].tokenPosition = this.yellowInitital.first;
          this.yellowInitital.removeAt(0);
        }
        break;
      case TokenType.blue:
        {
          this.gameTokens[token.id].tokenState = TokenState.initial;
          this.gameTokens[token.id].tokenPosition = this.blueInitital.first;
          this.blueInitital.removeAt(0);
        }
        break;
      case TokenType.red:
        {
          this.gameTokens[token.id].tokenState = TokenState.initial;
          this.gameTokens[token.id].tokenPosition = this.redInitital.first;
          this.redInitital.removeAt(0);
        }
        break;
    }
  }

  Position _getPosition(TokenType type, step) {
    Position destination;
    switch (type) {
      case TokenType.green:
        {
          List<int> node = Path.greenPath[step];
          destination = Position(node[0], node[1]);
        }
        break;
      case TokenType.yellow:
        {
          List<int> node = Path.yellowPath[step];
          destination = Position(node[0], node[1]);
        }
        break;
      case TokenType.blue:
        {
          List<int> node = Path.bluePath[step];
          destination = Position(node[0], node[1]);
        }
        break;
      case TokenType.red:
        {
          List<int> node = Path.redPath[step];
          destination = Position(node[0], node[1]);
        }
        break;
    }
    return destination;
  }

  assignUserToToken(
      TokenType tokenType, DiceModel dice, String name, BuildContext context) {
    bool canEnterGame = false;
    var isCanEnterGameArr = [];
    for (int i = 0; i < gameTokens.length; i++) {
      Token token = gameTokens[i];
      if (token.type == tokenType && token.userModel?.id == null) {
        // token.userModel?.id = socket.id;
        // token.userModel?.turn = token.turn;
        token.userModel = UserModel(socket.id, token.turn, name);
        userModel = UserModel(socket.id, token.turn, name);
        // userModel?.turn = token.turn;
        Get.log("user Model ${userModel?.id}, ${userModel?.turn}");

        isCanEnterGameArr.add(true);
      } else {
        isCanEnterGameArr.add(false);
      }
    }
    canEnterGame = isCanEnterGameArr.contains(true);
    if (canEnterGame == true) {
      socket.emit('join_game', {
        "playerId": socket.id,
        "tokenType": tokenType.toString(),
        "name": name
      });
      updateGameStateToSocket();
      listentoDiceStateSocket(dice);
      notifyListeners();
      socket.on('gameHasStarted', (data) {
        Get.log("Game Has Started Fired:::");
        // updateYourRoundEvent();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => GameHome(
                title: "Game Home", socket: socket, userModel: userModel)));
      });
      // Navigator.of(context).push(MaterialPageRoute(
      //     builder: (context) => GameHome(title: "Game Home")));
    } else {
      Get.snackbar('Info', "Token taken already",
          snackPosition: SnackPosition.BOTTOM);
    }
    notifyListeners();
  }

  listentoDiceStateSocket(DiceModel dice) {
    // //listen for when Dice State Changes.
    socket.on('dice_state_changed', (data) {
      print(data); //
      // isLoading.value = true;
      dice.diceOne = data['dice_number'];
      // dice.diceOneCount =

      print("Current socket Dice ${data['dice_number']}");
      print("Current assigned socket Dice ${dice.diceOne}");

      // isLoading.value = false;
      notifyListeners();
    });
    notifyListeners();
  }

  updateGameStateToSocket() {
    Future.delayed(const Duration(milliseconds: 50), () {
      socket.emit(
          'game_state',
          json.encode({
            "game_tokens": _destructureGameTokens(),
            "green_initial": _destrusturePositions(greenInitital),
            "red_initial": _destrusturePositions(redInitital),
            "yellow_initial": _destrusturePositions(yellowInitital),
            "blue_initial": _destrusturePositions(blueInitital),
            "star_positions": _destrusturePositions(starPositions),
            "should_play": shouldPlay,
            "current_turn": currentTurn,
            "number_of_times_rolled": numberOfTimesRolled,
            "current_turn_index": currentTurnIndex,
            "turns": turns,
            "currentPlayerHasPlayed": currentPlayerHasPlayed,
            "winnersArray": winnersArray,
            "arrivedTokens": arrivedTokens,
          }));
    });

    // notifyListeners();
  }

  List<Map<String, dynamic>> _destrusturePositions(
      List<Position> initialPositions) {
    List<Map<String, dynamic>> positions = [];
    for (int i = 0; i < initialPositions.length; i++) {
      Position pos = initialPositions[i];
      positions.add({"row": pos.row, "column": pos.row});
    }
    return positions.toList();
  }

  encodeGameToken(Token token) {
    return {
      "id": token.id,
      "type": token.type.toString(),
      "tokenPosition": {
        "row": token.tokenPosition.row,
        "column": token.tokenPosition.column
      },
      "tokenState": token.tokenState.toString(),
      "positionInPath": token.positionInPath,
      "turn": token.turn,
      "userModel": {
        "id": token.userModel?.id,
        "turn": token.userModel?.turn,
        "name": token.userModel?.name
      }
    };
  }

  List<Map<String, dynamic>> _destructureGameTokens() {
    List<Map<String, dynamic>> mappedGameTokens = [];
    for (int i = 0; i < gameTokens.length; i++) {
      Token token = gameTokens[i];
      mappedGameTokens.add({
        "id": token.id,
        "type": token.type.toString(),
        "tokenPosition": {
          "row": token.tokenPosition.row,
          "column": token.tokenPosition.column
        },
        "tokenState": token.tokenState.toString(),
        "positionInPath": token.positionInPath,
        "turn": token.turn,
        "userModel": {
          "id": token.userModel?.id,
          "turn": token.userModel?.turn,
          "name": token.userModel?.name
        }
      });
      print("Position in path ${token.positionInPath}");
    }

    return mappedGameTokens.toList();
  }

  Token decodeSingleGameToken(dynamic data) {
    var type = TokenType.values.firstWhere((e) => e.toString() == data['type']);
    var tokenPosition =
        Position(data['tokenPosition']['row'], data['tokenPosition']['column']);
    var tokenState =
        TokenState.values.firstWhere((e) => e.toString() == data['tokenState']);
    var tokenUserModel = UserModel(data['userModel']['id'],
        data['userModel']['turn'], data['userModel']['name']);
    var tokenId = data['id'];
    var tokenTurn = data['turn'];
    var positionInPath = data['positionInPath'];
    return Token(type, tokenPosition, tokenState, tokenId, tokenTurn,
        userModel: tokenUserModel, positionInPath: positionInPath);
  }

  decodeSocketGameTokens(List<dynamic> data) {
    for (int i = 0; i < data.length; i++) {
      dynamic dataObject = data[i];
      // gameTokens[i].tokenPosition = Position(dataObject['tokenPosition']['row'],
      //     dataObject['tokenPosition']['column']);

      // gameTokens[i].tokenState = TokenState.values
      //     .firstWhere((e) => e.toString() == dataObject['tokenState']);
      gameTokens[i].positionInPath = dataObject['positionInPath'];
      gameTokens[i].userModel = UserModel(dataObject['userModel']['id'],
          dataObject['userModel']['turn'], dataObject['userModel']['name']);
      notifyListeners();
    }
    notifyListeners();
  }

  decodeWinnersArrayAndArrivedTokensArray(
      List<dynamic> data1, List<dynamic> data2) {
    winnersArray = data1;
    arrivedTokens = data2;

    notifyListeners();
  }

  updateCurrentPlayerHasPlayed(bool status) {
    currentPlayerHasPlayed = status;
    updateGameStateToSocket();
  }

  checkShouldPlay(int steps) {
    if (userModel.turn == currentTurn && steps == 6) {
      Get.log("User Model turn ${userModel.turn}");
      Get.log("Current Turn $currentTurn");
      shouldPlay = true;
      updateCurrentPlayerHasPlayed(false);
      updateGameStateToSocket();
    } else if (userModel.turn == currentTurn && steps != 6) {
      var tokens = this
          .gameTokens
          .where((element) =>
              element.turn == userModel.turn &&
              element.tokenState == TokenState.initial)
          .toList();
      var tokesNotInInitial = this
          .gameTokens
          .where((element) =>
              element.turn == userModel.turn &&
              element.tokenState != TokenState.initial)
          .toList();
      if (tokens.isEmpty) {
        shouldPlay = true;
        updateCurrentPlayerHasPlayed(false);
      } else if (tokesNotInInitial.length > 0) {
        shouldPlay = true;
        updateCurrentPlayerHasPlayed(false);
      } else {
        shouldPlay = false;
        updateCurrentPlayerHasPlayed(true);
      }
    }
  }

  updateGameTurn(int steps) {
    // notifyListeners();
    // if (steps != 6) {
    var future = Future.delayed(const Duration(seconds: 1), () {
      updateCurrentTurnNew();
    });
    // }
    // updateGameStateToSocket();
    // notifyListeners();
  }

  dicerollSocket(DiceModel dice) {
    socket.emit('throw',
        {"dice_number": dice.diceOne, "dice_number_count": dice.diceOneCount});
    // //listen for when Dice State Changes.
    socket.on('throw', (data) {
      dice.diceOne = data['dice_number'];
      notifyListeners();
      // dice.diceOne = 6;

      Get.log("Current socket Dice ${data['dice_number']}");
      Get.log("Current assigned socket Dice ${dice.diceOne}");
    });
  }

  updateCurrentTurnNew() {
    if (currentTurnIndex + 1 < turns.length) {
      currentTurnIndex = currentTurnIndex + 1;
      currentTurn = turns[currentTurnIndex];
      updateYourRoundEvent();
      Future.delayed(const Duration(seconds: 1), () {
        updateGameStateToSocket();
      });
    } else {
      currentTurnIndex = 0;
      currentTurn = turns[0];
      updateYourRoundEvent();
      Future.delayed(const Duration(seconds: 1), () {
        updateGameStateToSocket();
      });
    }

    // updateGameStateToSocket();

    // notifyListeners();
  }

  updateYourRoundEvent() {
    socket.emit('yourRound', {"currentTurnIndex": currentTurnIndex});
  }
}
