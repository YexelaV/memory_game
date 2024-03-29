import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'config.dart';

class MyText extends StatelessWidget{
  int _param;
  String _text;
  double _width;

  MyText (param, text, width) {
    this._param = param;
    this._text = text;
    this._width = width;
  }
  @override
  Widget build(BuildContext context){
    return Container(
        width: MediaQuery.of(context).size.width*_width,
        child: Text(
            '$_text $_param', style: TextStyle(fontSize: fontSize,
            color: Colors.black,
            decoration: TextDecoration.none), textScaleFactor: 1.0)
    );
  }
}

class NewGame extends StatefulWidget {
  @override
  createState()=> NewGameState();
}


enum gameMode {easy, hard}

class NewGameState extends State<NewGame> {

  static List <Color> _colors = [
    Colors.pink,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.cyan[100],
    Colors.blue,
    Colors.purple,];

  static List <IconData> _icons = [
    Icons.local_florist,
    Icons.beach_access,
    Icons.favorite,
    Icons.pets,
    Icons.star,
    Icons.vpn_key,
    Icons.cloud,
    Icons.flight,
    Icons.airport_shuttle,
    Icons.battery_full,
    Icons.brightness_3,
    Icons.child_friendly,
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.directions_railway,


  ];
  static List <IconData> _usedIcons =[];

  List <Color> _displayedColors=[];
  List <Color> _playerColors=[];
  List <Color> _savedColors=[];
  List <Color> _borderColors = [];

  List <Color> _displayedIconColor = [];
  List <Color> _playerIconColor = [];

  List <IconData> _displayedIcons = [];
  List <IconData> _playerIcons=[];
  List <IconData> _savedIcons=[];

  int _level = 1;
  int _itemsToRemember = 3;
  int _iconsToUse = 3;
  int _colorsToUse = 3;
  int _lifes = 3;
  bool _easyGameMode; //false for hard game mode
  int _score = 0;
  int _highScore;
  int _matchedNumber = 0;
  int _currentButton;
  bool _keyboardActive = false;
  bool _showStart = true;
  Random randomIcon = Random();
  Random randomColor = Random();
  Canvas canvas;

  void initState() {
    super.initState();
    _getGameMode();
    for (int i=0; i<_itemsToRemember; i++) {
      _playerColors.add(Colors.white70);
      _playerIcons.add(Icons.brightness_1);
      _savedColors.add(Colors.transparent);
      _savedIcons.add(Icons.brightness_1);
      _displayedColors.add(Colors.transparent);
      _displayedIcons.add(Icons.brightness_1);
      _borderColors.add(Colors.transparent);
      _displayedIconColor.add(Colors.transparent);
      _playerIconColor.add(Colors.transparent);
    }
  }

  Future _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt('highscore') ?? 0;
    setState(() {
    });
  }

  Future _putHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highscore', score);
  }

   Future _getGameMode() async {
     final prefs = await SharedPreferences.getInstance();
     bool _boolGameMode = prefs.getBool('gameMode') ?? true;
     _easyGameMode = !_boolGameMode;
   }

  Future _start() async{
    _currentButton=0;
    int color = randomColor.nextInt(_colorsToUse);
    int nextColor = randomColor.nextInt(_colorsToUse);
    int icon = randomIcon.nextInt(_iconsToUse);
    int nextIcon;
    if (!_easyGameMode) nextIcon = randomIcon.nextInt(_iconsToUse);
    else nextIcon = randomIcon.nextInt(_icons.length-1);

    for (int i=0; i<_itemsToRemember; i++)  {
      await Future.delayed(Duration(milliseconds: delayBeforeShow));
      if (_colorsToUse>2) while (nextColor == color) nextColor = randomColor.nextInt(_colorsToUse);
      if (_iconsToUse>2) while (nextIcon == icon) nextIcon = randomIcon.nextInt(_iconsToUse);
      setState(() {
        _savedColors[i] = _displayedColors[i] = _colors[color];
        _savedIcons[i] = _displayedIcons[i] = _icons[icon];
        if (_easyGameMode) _playerIcons[i]=_savedIcons[i];
        else _playerIcons[i]=Icons.brightness_1;
        _displayedIconColor[i] = Colors.black;
      });
      color = nextColor;
      icon = nextIcon;
    }
    int _delay = delayToMemorize;
    if (!_easyGameMode) _delay=delayToMemorize*2;
    await Future.delayed(Duration(milliseconds: _itemsToRemember*_delay));
    for (int i=0; i<_itemsToRemember; i++)  setState(() {
      _displayedColors[i] = Colors.transparent;
      _displayedIconColor[i] = Colors.transparent;
      if (_easyGameMode) _playerIconColor[i]=Colors.black;
    });
    _borderColors[0]=Colors.black;
    _keyboardActive = true;
  }

  _onTapColor(int colorIndex) {
    setState(() {
      _playerColors[_currentButton] = _colors[colorIndex];
      if ((_currentButton<_itemsToRemember)&((_playerIcons[_currentButton]!=Icons.brightness_1)|_easyGameMode)){
        _borderColors[_currentButton]=Colors.transparent;
        _currentButton+=1;
        if (_currentButton == _itemsToRemember) _check();
        else _borderColors[_currentButton]=Colors.black;
      }
    });
  }

  _onTapIcon(int iconIndex) {
    setState(() {
      _playerIcons[_currentButton] = _icons[iconIndex];
      _playerIconColor[_currentButton] = Colors.black;
      if ((_currentButton<_itemsToRemember)&(_playerColors[_currentButton]!=Colors.white70)){
        _borderColors[_currentButton]=Colors.transparent;
        _currentButton+=1;
        if (_currentButton == _itemsToRemember) _check();
        else _borderColors[_currentButton]=Colors.black;
      }
    });
  }

  Future _check() async {
    _keyboardActive = false;
    for (int i = 0; i < _itemsToRemember; i++) {
      await Future.delayed(Duration(milliseconds: delayWhileChecking));
      setState(() {
        _displayedColors[i] = _savedColors[i];
        _displayedIcons[i] = _savedIcons[i];
        _displayedIconColor[i] = Colors.black;
        if ((_savedColors[i] == _playerColors[i])&((_savedIcons[i]==_playerIcons[i])|_easyGameMode))
          {
            _matchedNumber += 1;
            _score+=_level*(_itemsToRemember-1);
          }
      });
    }

    if (_matchedNumber==_itemsToRemember) {
      _matchedNumber = 0;
      await Future.delayed(Duration(milliseconds: delayBetweenlevels));
      if (_level == 25) {
        _showMessage(context, "CONGRATULATIONS! YOU PASSED ALL LEVELS!");
      }
      else {
        setState(() {
          for (int i = 0; i < _itemsToRemember; i++) {
            _playerColors[i] = Colors.white70;
            _displayedColors[i] = Colors.transparent;
            _displayedIconColor[i] = Colors.transparent;
            _borderColors[i] = Colors.transparent;
            _playerIconColor[i] = Colors.transparent;
          }
          if (_level % 5 == 0) {
            _colorsToUse++;
            _itemsToRemember = 3;
            // _displayedColors = [Colors.transparent,Colors.transparent];
            // _playerColors = [Colors.white70, Colors.white70];
            // _savedColors = [Colors.transparent, Colors.transparent];
          }
          //if (_colorsToUse>_colors.length) {_colorsToUse = 3; _itemsToRemember = 2;}
          else {
            _itemsToRemember++;
            _score += 10;
            _playerColors.add(Colors.white70);
            _playerIcons.add(Icons.brightness_1);
            _savedColors.add(Colors.transparent);
            _savedIcons.add(Icons.brightness_1);
            _displayedColors.add(Colors.transparent);
            _borderColors.add(Colors.transparent);
            _displayedIcons.add(Icons.brightness_1);
            _displayedIconColor.add(Colors.transparent);
            _playerIconColor.add(Colors.transparent);
          }
          _level++;
        });
        _start();
      }
    }
    else {
      _lifes--;
      _matchedNumber=0;
      if (_lifes==0){
        await Future.delayed(Duration(milliseconds: delayBetweenlevels));
        _showMessage(context, "GAME OVER");
        _matchedNumber = 0;
        if (_score>_highScore)
        {
          _putHighScore(_score);
          _highScore = _score;
        }
      }
      else {
        await Future.delayed(Duration(milliseconds: delayBetweenlevels));
        setState(() {
          for (int i = 0; i < _itemsToRemember; i++) {
            _playerColors[i] = Colors.white70;
            _playerIcons[i] = Icons.brightness_1;
            _playerIconColor[i]=Colors.transparent;
            _displayedColors[i] = Colors.transparent;
            _displayedIconColor[i]=Colors.transparent;
            _borderColors[i] = Colors.transparent;
          }
          });
        _start();
      }
    }
  }

   _showMessage (BuildContext context, String message){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
        onWillPop: () async => false,
            child: AlertDialog(
              title: Text(message),
              content: Text("Your score: $_score", textScaleFactor: 1.0),
                actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _score=0;
                },
                    child: Text('OK', textScaleFactor: 1.0)
                ),
                ]
            )
        )
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) =>
      new AlertDialog(
        title: new Text('Back to Main Menu',textScaleFactor: 1.0),
        content: new Text('All game progress will be lost. Are you sure?',textScaleFactor: 1.0),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No',textScaleFactor: 1.0),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes',textScaleFactor: 1.0),
          ),
        ],
      ),
    )
        ?? false;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
      _getHighScore();
    return WillPopScope(
        onWillPop: (_onWillPop) ,
      child: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backgrounds/bg_newgame.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Scaffold (
                    backgroundColor: Colors.transparent,
                  appBar: PreferredSize(
                  preferredSize: Size.fromHeight(40.0),
                  child: AppBar(
                    centerTitle: true,
                    title: Text(
                      'LEVEL $_level',
                        textScaleFactor: 1.0,
                      style: TextStyle(fontSize: 20, color: Colors.black, decoration: TextDecoration.none)
                    ),
                    backgroundColor: Colors.transparent,
                    )
                    ),
                    body: Center(
                    child: Column(
                    children: <Widget>[
                      //SizedBox(height: paddingFromTop),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:<Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                          child: FlatButton(
                              disabledColor: Colors.white70,
                            child: Text(
                                'SCORE: $_score', style: TextStyle(fontSize: 15,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                                textScaleFactor: 1.0,
                                textAlign: TextAlign.left
                            )
                        )
                          ),
                          Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Row(
                          children:<Widget>[
                            FlatButton(
                              disabledColor: Colors.white70,
                              child: Text(
                                  'LIFES', style: TextStyle(fontSize: 15,
                                  color: Colors.black,
                                  decoration: TextDecoration.none),
                                  textScaleFactor: 1.0,
                                  textAlign: TextAlign.left
                              )
                          ),
                            for (int i=0; i<_lifes; i++) Icon(Icons.favorite, color:Colors.pink)
                          ]
                          )
                          ),
                          Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: FlatButton(
                              disabledColor: Colors.white70,
                              child: Text(
                                  'HIGH SCORE: $_highScore', style: TextStyle(fontSize: 15,
                                  color: Colors.black,
                                  decoration: TextDecoration.none),
                                  textScaleFactor: 1.0,
                                  textAlign: TextAlign.right
                              )
                          )
                          ),
                          //MyText (_level, "LEVEL",0.2)
                        ]
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:<Widget>[
                      ]),
                      //Buttons to memorize
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          for (int i=0; i<_itemsToRemember; i++) Container(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB (5.0, 1.5, 5.0, 0.0),
                                child: Ink(
                                    width: 45,
                                    height: 45,
                                    decoration: ShapeDecoration(
                                        color: _displayedColors[i],
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                            side: BorderSide(color: Colors.transparent, width:2))),
                                        child: IconButton(
                                          icon: Icon (_displayedIcons[i]),
                                          iconSize: 25,
                                          disabledColor: _displayedIconColor[i],
                                    )
                                ),
                            )
                          ),
                          ]
                      ),

                        //Buttons to enter answer
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              for (int i=0;i<_itemsToRemember; i++) Container(
                                    child: Padding(
                                    padding: EdgeInsets.fromLTRB (5.0, 1.5, 5.0, 5.0),
                                    child: Ink(
                                      width: 45,
                                      height: 45,
                                      decoration: ShapeDecoration(
                                          color: _playerColors[i],
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                              side: BorderSide(color: _borderColors[i], width:2))),
                                              child: IconButton(
                                                icon: Icon (_playerIcons[i]),
                                                iconSize: 25,
                                                disabledColor: _playerIconColor[i]
                                                  )
                                                ),
                                          )
                              )
                            ]
                        ),

                        //Button keyboard
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (int i=0;i<_colorsToUse;i++ ) Container (
                                //decoration: BoxDecoration(color: Colors.white, border: Border.all(color:Colors.black, width:borderWidth)),
                                child: SizedBox(
                                height: keyboardButtonHeight,
                                width: keyboardButtonWidth,
                                child: Ink(
                                    decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                            side: BorderSide(color: Colors.black))),
                                    child: IconButton(
                                      icon: Icon (Icons.brightness_1),
                                      color: _colors[i],
                                      iconSize: 25,
                                      onPressed: () {if (_keyboardActive)
                                        _onTapColor(i);},
                                    )
                                )
                                )
                                ),
                            Container(
                              child: SizedBox(
                                height: keyboardButtonHeight,
                                width: keyboardButtonWidth,
                                    child: Ink(
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          side: BorderSide(color: Colors.black))),
                                    child: IconButton(
                                      icon: Icon (Icons.arrow_back),
                                      iconSize: 25,
                                      onPressed: () {
                                        if (_keyboardActive){
                                        if (_currentButton>0) {
                                        _playerColors[_currentButton]=Colors.white70;
                                        _borderColors[_currentButton]=Colors.transparent;
                                        if (!_easyGameMode) _playerIconColor[_currentButton] = Colors.transparent;
                                        if (!_easyGameMode) _playerIcons[_currentButton]=Icons.brightness_1;
                                        _currentButton--;
                                        _playerColors[_currentButton]=Colors.white70;
                                        if(!_easyGameMode) _playerIconColor[_currentButton] = Colors.transparent;
                                        _borderColors[_currentButton]=Colors.black;
                                        if (!_easyGameMode) _playerIcons[_currentButton]=Icons.brightness_1;
                                        }
                                        }
                                      },
                                    )
                                    ),
                                ),
                                )
                              ]
                            ),
                      //SizedBox(height: intervalBetweenButtons),
                      Row (
                        children: <Widget>[
                        if (_showStart) SizedBox(height:intervalBetweenButtons)
                        ]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (_showStart)
                            SizedBox(
                              height: 50,
                              width: 100,
                              child:
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(10.0),
                                side: BorderSide(color: Colors.blue)
                                ),
                                child: Text(
                                    'START',
                                    textScaleFactor: 1.0,
                                    style: TextStyle(fontSize: 20)),
                                onPressed: () {
                                  _showStart = false;
                                  _start();
                                },
                                highlightColor: Colors.blue,
                                color: Colors.lightBlue,
                              )
                          )
                          else
                            if (!_easyGameMode) Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                  for (int i=0;i<_iconsToUse;i++ ) Container (
                                      child: SizedBox(
                                        height: keyboardButtonHeight,
                                        width: keyboardButtonWidth,
                                        child: Ink(
                                          decoration: ShapeDecoration(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                            side: BorderSide(color: Colors.black, width:1))),
                                          child: IconButton(
                                            icon: Icon (_icons[i]),
                                            iconSize: 25,
                                            disabledColor: Colors.black,
                                            onPressed:() {if (_keyboardActive) _onTapIcon(i);}
                                          )
                                        ),
                                      )
                                  ),
                                  ]
                          )
                        ],
                      ),
                    ]
                )
              )
                    )
            )
          ]
      )
    );
    }
  }

