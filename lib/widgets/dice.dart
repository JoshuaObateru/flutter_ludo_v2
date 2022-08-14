import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../gameengine/model/dice_model.dart';
import '../gameengine/model/game_state.dart';

class Dice extends StatelessWidget {
  Future<void> updateDices(DiceModel dice, GameState gameState) async {
    Get.log("Current Player Has Played ${!gameState.currentPlayerHasPlayed}");
    if (!gameState.currentPlayerHasPlayed) return;
    for (int i = 0; i < 6; i++) {
      var duration = 100 + i * 100;
      // gameState.dicerollSocket(dice);
      var future = Future.delayed(Duration(milliseconds: duration), () {
        dice.generateDiceOne();
        gameState.dicerollSocket(dice);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> _diceOneImages = [
      "assets/1.png",
      "assets/2.png",
      "assets/3.png",
      "assets/4.png",
      "assets/5.png",
      "assets/6.png",
    ];
    final dice = Provider.of<DiceModel>(context);
    final gameState = Provider.of<GameState>(context);
    final c = dice.diceOneCount;
    var img = Image.asset(
      _diceOneImages[c - 1],
      gaplessPlayback: true,
      fit: BoxFit.fill,
    );
    return Card(
      elevation: 10,
      child: Container(
        height: 40,
        width: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (gameState.userModel?.turn == gameState.currentTurn) {
                        await updateDices(dice, gameState);

                        var future =
                            Future.delayed(const Duration(seconds: 1), () {
                          gameState.checkShouldPlay(dice.diceOne);
                          // gameState.checkShouldPlay(6);
                          Get.log(
                              "ShouldPlay in Dice Widget ${gameState.shouldPlay}");
                          Future.delayed(const Duration(seconds: 1), () {
                            if (gameState.shouldPlay == false) {
                              gameState.updateGameTurn(dice.diceOne);
                            }
                          });
                        });
                      }

                      // gameState.updateGameTurn(dice.diceOne);

                      // print("c $c");
                      // print("diceoneee ${dice.diceOne}");
                    },
                    child: img,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
