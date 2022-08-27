import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../gameengine/model/game_state.dart';
import '../gameengine/model/token.dart';
import 'dice.dart';

class DiceTurnWidget extends StatelessWidget {
  const DiceTurnWidget(
      {Key key,
      this.isDiceLeading = false,
      this.turn,
      this.color,
      this.foregroundColor,
      this.token,
      this.isTop})
      : super(key: key);

  final bool isDiceLeading;
  final int turn;
  final Color color;
  final Color foregroundColor;
  final Token token;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<GameState>(builder: (context, gameState, child) {
      Get.log("::: Game State From Dice Turn ::: ${gameState.currentTurn}");
      return Column(
        crossAxisAlignment: isDiceLeading == true
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          isTop == true
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    token.userModel?.id != gameState.userModel?.id
                        ? '${token.userModel?.name}'
                        : '${token.userModel?.name}(You)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Container(),
          Card(
            elevation: 3,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              color: color ?? Colors.white,
              child: isDiceLeading == true
                  ? Row(
                      children: [
                        AnimatedPadding(
                          duration: Duration(milliseconds: 100),
                          padding: const EdgeInsets.all(8.0),
                          child: gameState.currentTurn == turn
                              ? Dice()
                              : Container(
                                  width: size.width * 0.1,
                                  height: size.height * 0.05,
                                  color: Colors.grey,
                                ),
                        ),
                        AnimatedPadding(
                          duration: Duration(milliseconds: 100),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "$turn",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: foregroundColor ?? Colors.black,
                                fontSize: size.width * 0.05),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        AnimatedPadding(
                          duration: Duration(milliseconds: 100),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "$turn",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: foregroundColor ?? Colors.black,
                                fontSize: size.width * 0.05),
                          ),
                        ),
                        AnimatedPadding(
                          duration: Duration(milliseconds: 100),
                          padding: const EdgeInsets.all(8.0),
                          child: gameState.currentTurn == turn
                              ? Dice()
                              : Container(
                                  width: size.width * 0.1,
                                  height: size.height * 0.05,
                                  color: Colors.grey,
                                ),
                        )
                      ],
                    ),
            ),
          ),
          isTop == false
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    token.userModel?.id != gameState.userModel?.id
                        ? '${token.userModel?.name}'
                        : '${token.userModel?.name}(You)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : Container(),
        ],
      );
    });
  }
}
