import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget{
  @override
  createState()=> SettingsState();
}

enum gameMode {easy, hard}

class SettingsState extends State<Settings>{

  gameMode _gameMode;

  Future _getGameMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool _boolGameMode = prefs.getBool('gameMode') ?? false;
    if (_boolGameMode) _gameMode = gameMode.easy;
    else _gameMode = gameMode.hard;
    setState((){});
  }

  Future _putGameMode(gameMode _gameMode) async {
      final prefs = await SharedPreferences.getInstance();
      if (_gameMode==gameMode.hard) prefs.setBool ('gameMode', true);
      else  prefs.setBool ('gameMode', false);
      setState(() {});

  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _getGameMode();
    //return WillPopScope(
      //onWillPop: () async => false,
      //child:
      return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('backgrounds/bg_settings.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                ),
                backgroundColor: Colors.transparent,
                body: Center(
                    child: Column (
                    children: <Widget> [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //SizedBox(height: paddingFromTop),
                          SizedBox(height: 100),
                          FlatButton(
                                    disabledColor: Colors.white,
                                    child: Text(
                                        'Select Game Mode',
                                        style: TextStyle(fontSize: 20, color: Colors.black, decoration: TextDecoration.none)
                                    )
                                ),
                        ]
                      ),
                      Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                              SizedBox (
                              width: 200,
                              child: FlatButton (
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: menuButtonHighlightColor)
                                ),
                              disabledColor: Colors.white,
                              child: ListTile(
                                title: const Text('Easy'),
                                leading: Radio(
                                  value: gameMode.easy,
                                  groupValue: _gameMode,
                                  onChanged: (gameMode value) {
                                    _putGameMode(_gameMode);
                                    setState(() { _gameMode = value; });
                                  },
                                ),
                              ),
                              ),
                              ),
                          ]
                      ),
                      SizedBox(height:10),
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                              SizedBox (
                                  width: 200,
                                  child: FlatButton (
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        side: BorderSide(color: menuButtonHighlightColor)
                                    ),
                                    disabledColor: Colors.white,
                              child: ListTile(
                                title: const Text('Hard'),
                                leading: Radio(
                                  value: gameMode.hard,
                                  groupValue: _gameMode,
                                  onChanged: (gameMode value) {
                                    _putGameMode(_gameMode);
                                    setState(() { _gameMode = value; });
                                  },
                                ),
                              ),
                              )
                              )
                          ]
                        )
                      ],

                    )
                )
            ),
          ]
      );
    //);
  }
}
