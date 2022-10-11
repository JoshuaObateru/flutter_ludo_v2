import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ludo/gameengine/model/user_model.dart';
import 'package:ludo/widgets/dice_turn_widget.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import './widgets/gameplay.dart';
import 'gameengine/model/game_state.dart';

class GameHome extends StatefulWidget {
  final Socket socket;
  final UserModel userModel;
  GameHome({Key key, this.title, this.socket, this.userModel})
      : super(key: key);
  final String title;
  @override
  _GameHomeState createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> {
  GlobalKey keyBar = GlobalKey();
  void onPressed() {}

  Timer countdownTimer;
  Duration myDuration = Duration(seconds: 30);

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = Duration(seconds: 30));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    Get.log("set Count Down called again!");
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer.cancel();
        widget.socket
            .emit('missedOpportunity', {"playerId": widget.userModel.id});
        Get.log("Cancelled!");
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final gameState = Provider.of<GameState>(context);

    String strDigits(int n) => n.toString().padLeft(2, '0');

    final seconds = strDigits(myDuration.inSeconds.remainder(30));

    // if (gameState.currentPlayerId == gameState.userModel.id &&
    //     (countdownTimer == null || !countdownTimer.isActive)) {
    //   if (countdownTimer != null) {
    //     resetTimer();
    //   }
    //   startTimer();
    // }
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
        // child: Container(
        //     height: 50.0,
        //     child: gameState.currentPlayerId == gameState.userModel.id
        //         ? Center(
        //             child: Text(
        //               'Your Round ${seconds}s remaining',
        //               style:
        //                   TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        //             ),
        //           )
        //         : Offstage()),
      ),
    );
  }
}
