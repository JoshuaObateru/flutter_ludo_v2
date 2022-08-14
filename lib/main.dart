import 'package:flutter/material.dart';
import 'package:ludo/widgets/select_token_view.dart';
import './gameengine/model/game_state.dart';
import 'package:provider/provider.dart';
import './gameengine/model/dice_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => DiceModel()),
          ChangeNotifierProvider(create: (context) => GameState()),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SelectTokenView(),
        ));
  }
}
