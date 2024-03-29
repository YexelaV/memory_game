import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'newgame.dart';
import 'settings.dart';
import 'package:audioplayers/audio_cache.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
    routes: {
      '/new': (BuildContext context) => NewGame(),
      '/settings':  (BuildContext context) => Settings()
    }
  ));
}

class MenuButton extends StatelessWidget{

  String _name;
  MenuButton (String name){
    this._name=name;
  }

  void _action (BuildContext context){
    if (_name=="New Game") Navigator.pushNamed(context, '/new');
    if (_name=="Settings") Navigator.pushNamed(context, '/settings');
}

  static AudioCache player = AudioCache();

  @override
  Widget build (BuildContext context){
    return   SizedBox(
        height: menuButtonHeight,
        width: menuButtonWidth,
        child: RaisedButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: menuButtonHighlightColor)
            ),
          child: Text(
            _name,
            textScaleFactor: 1.5,
            //style: TextStyle(fontSize: menuButtonFontSize)
            ),
            onPressed: () {
              player.play('sound/menu.wav');
              _action(context);},
        highlightColor: menuButtonHighlightColor,
        color: menuButtonColor
    )
    );
  }
}

class MainScreen extends StatefulWidget {
  createState()=>MainScreenState();
}


class MainScreenState extends State<MainScreen> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight]);
      return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/backgrounds/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: intervalBetweenMenuButtons),
                    MenuButton("New Game"),
                    SizedBox(height: intervalBetweenMenuButtons),
                    MenuButton("Settings"),
                  ],
                ),
              ),
            )
          ]
      );
  }
}