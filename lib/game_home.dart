import 'package:flutter/material.dart';
import 'package:ludo/widgets/dice_turn_widget.dart';
import 'package:provider/provider.dart';
import './widgets/gameplay.dart';
import 'gameengine/model/game_state.dart';

class GameHome extends StatefulWidget {
  GameHome({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _GameHomeState createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  GlobalKey keyBar = GlobalKey();
  void onPressed() {}
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final gameState = Provider.of<GameState>(context);
    return Scaffold(
      appBar: AppBar(
        key: keyBar,
        title: Text('Ludo'),
      ),
      body: Stack(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GamePlay(keyBar, gameState),
          Positioned(
            top: size.height * 0.02,
            left: 0,
            child: DiceTurnWidget(
              turn: 1,
              token: gameState.gameTokens[0],
              isTop: true,
            ),
          ),
          Positioned(
              top: size.height * 0.02,
              right: 0,
              child: DiceTurnWidget(
                isDiceLeading: true,
                turn: 2,
                isTop: true,
                token: gameState.gameTokens[4],
              )),
          Positioned(
              bottom: size.height * 0.02,
              right: 0,
              child: DiceTurnWidget(
                isDiceLeading: true,
                turn: 3,
                isTop: false,
                token: gameState.gameTokens[8],
              )),
          Positioned(
              bottom: size.height * 0.02,
              left: 0,
              child: DiceTurnWidget(
                turn: 4,
                isTop: false,
                token: gameState.gameTokens[12],
              )),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
        ),
      ),
      // floatingActionButton: Dice(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
