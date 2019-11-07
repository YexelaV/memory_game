import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'config.dart';


class DrawCircle extends CustomPainter {
  Paint _paint;
  double _size;
  DrawCircle(Color color, double circleSize) {
    _size = circleSize;
    _paint = Paint()
      ..color = color
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(0.0, 0.0), _size, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

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
            decoration: TextDecoration.none))
    );
  }
}

class NewGame extends StatefulWidget {
  @override
  createState()=> NewGameState();
}

class NewGameState extends State<NewGame> {

  static List <Color> _colors = [
    Colors.pink,
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.lightBlue[100],
    Colors.blue,
    Colors.deepPurple];
  static List <IconData> _icons = [
    Icons.flight,
    Icons.airport_shuttle,
    Icons.battery_full,
    Icons.beach_access,
    Icons.brightness_3,
    Icons.child_friendly,
    Icons.cloud,
    Icons.directions_bike,
    Icons.directions_boat,
    Icons.directions_railway,
    Icons.local_bar,
    Icons.local_florist,
    Icons.pets,
    Icons.star,
    Icons.vpn_key
  ];
  static List <IconData> _usedIcons =[];

  List <Color> _playerColors=[];
  List <Color> _savedColors=[];
  List <Color> _displayedColors=[];
  List <Color> _borderColors = [];
  
  List <IconData> _playerIcons=[];
  List <IconData> _savedIcons=[];
  List <IconData> _displayedIcons = [];
  
  int _level = 1;
  int _itemsToRemember = 3;
  int _iconsToUse = 2;
  int _colorsToUse = 3;
  int _lifes = 3;
  int _score = 0;
  int _highScore;
  int _matchedNumber = 0;
  int _currentButton;
  bool _keyboardActive = false;
  bool _showStart = true;
  Random random = Random();
  Canvas canvas;

  void initState() {
    super.initState();
    for (int i=0; i<_itemsToRemember; i++) {
      _playerColors.add(Colors.white70);
      _savedColors.add(Colors.transparent);
      _displayedColors.add(Colors.transparent);
      _displayedIcons.add(Icons.brightness_1);
      _borderColors.add(Colors.transparent);
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


  Future _start() async{
    _currentButton=0;
    int color = random.nextInt(_colorsToUse);
    int nextColor = random.nextInt(_colorsToUse);

    int icon = random.nextInt(_iconsToUse);
    int nextIcon = random.nextInt(_iconsToUse);

    for (int i=0; i<_itemsToRemember; i++)  {
      await Future.delayed(Duration(milliseconds: delayBeforeShow));
      while (nextColor == color) {nextColor = random.nextInt(_iconsToUse);}
      while (nextIcon == icon) {nextIcon = random.nextInt(_iconsToUse);}
      setState(() {
        _savedColors[i] = _displayedColors[i] = _colors[color];
        _displayedIcons[i] = _icons[icon];
      });
      color = nextColor;
      icon = nextIcon;
    }

    await Future.delayed(Duration(milliseconds: _itemsToRemember*delayToMemorize));
    for (int i=0; i<_itemsToRemember; i++)  setState(()
    {_displayedColors[i] = Colors.transparent;});
    _borderColors[0]=Colors.black;
    _keyboardActive = true;
  }

  _onTap(int color) {
    setState(() {
      _playerColors[_currentButton] = _colors[color];
      _borderColors[_currentButton]=Colors.transparent;
      if (_currentButton<_displayedColors.length-1){
        _currentButton+=1;
        _borderColors[_currentButton]=Colors.black;
      }
      else _check();
    });
  }

  Future _check() async {
    _keyboardActive = false;
    for (int i = 0; i < _itemsToRemember; i++) {
      await Future.delayed(Duration(milliseconds: delayWhileChecking));
      setState(() {
        _displayedColors[i] = _savedColors[i];
        if (_savedColors[i] == _playerColors[i])
          {
            _matchedNumber += 1;
            _score+=_level*(_colorsToUse-2);
          }
      });
    }

    if (_matchedNumber==_itemsToRemember) {
      //_showMessage(context, "Congratulations! You passed to the next level!");
      _matchedNumber = 0;
      await Future.delayed(Duration(milliseconds: delayBetweenlevels));
      setState((){
        for (int i=0; i<_itemsToRemember; i++) {
          _playerColors[i] = Colors.white70;
          _displayedColors[i] = Colors.transparent;
          _borderColors[i] = Colors.transparent;
        }
        if (_level%5==0) {
          _colorsToUse++;
          _itemsToRemember = 2;
          _displayedColors = [Colors.transparent,Colors.transparent];
          _playerColors = [Colors.white70, Colors.white70];
          _savedColors = [Colors.transparent, Colors.transparent];
        }
        if (_colorsToUse>_colors.length) {_colorsToUse = 3; _itemsToRemember = 2;}
        _level++;
        _itemsToRemember++;
        _score+=10;
        _playerColors.add(Colors.white70);
        _savedColors.add(Colors.transparent);
        _displayedColors.add(Colors.transparent);
        _borderColors.add(Colors.transparent);
        _displayedIcons.add(Icons.brightness_1);
      });
      _start();
    }
    else {
      _lifes--;
      _matchedNumber=0;
      if (_lifes==0){
        await Future.delayed(Duration(milliseconds: delayBetweenlevels));
        _showMessage(context, "Unfortunately, you lose. Try again");
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
            _displayedColors[i] = Colors.transparent;
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
              content: Text("Your score: $_score"),
                actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _score=0;
                },
                    child: Text('OK')
                ),
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
      _getHighScore();
    return new WillPopScope(
        onWillPop: () async => false,
      child: Stack(
          children: [
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('backgrounds/bg_newgame.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Scaffold (
                    backgroundColor: Colors.transparent,
                    body: Center(
                    child: Column(
                    children: <Widget>[
                      SizedBox(height: paddingFromTop),
                      Container(
                          child: Text(
                              'LEVEL $_level', style: TextStyle(fontSize: fontSize,
                              color: Colors.black,
                              decoration: TextDecoration.none))
                      ),
                      SizedBox(height: intervalBetweenText),
                      Row(
                        children:<Widget>[
                          Container(width: MediaQuery.of(context).size.width*0.05),
                          Container(
                            width: MediaQuery.of(context).size.width*0.45,
                            child: Text(
                                'YOUR SCORE: $_score', style: TextStyle(fontSize: fontSize,
                                color: Colors.black,
                                decoration: TextDecoration.none),
                                textAlign: TextAlign.left
                            )
                        ),
                          Container(
                              width: MediaQuery.of(context).size.width*0.45,
                              child: Text(
                                  'HIGH SCORE: $_highScore', style: TextStyle(fontSize: fontSize,
                                  color: Colors.black,
                                  decoration: TextDecoration.none),
                                  textAlign: TextAlign.right
                              )
                          ),
                          Container(width: MediaQuery.of(context).size.width*0.05),
                          //MyText (_level, "LEVEL",0.2)
                        ]
                      ),
                      Row(
                          children:<Widget>[
                            Container(width: MediaQuery.of(context).size.width*0.05),
                            Container(
                                width: MediaQuery.of(context).size.width*0.45,
                                child: Text(
                                    'LIFES: $_lifes', style: TextStyle(fontSize: fontSize,
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                                    textAlign: TextAlign.left
                                )
                            ),
                      ]),

                      
                      //Buttons to remember
                      /*Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          for (int i=0; i<_itemsToRemember; i++) Container(
                            decoration: BoxDecoration(border: Border.all(color:Colors.transparent, width: borderWidth)),
                            child: SizedBox(
                                height: buttonHeight,
                                width: buttonWidth,
                                child:
                                FloatingActionButton(
                                    heroTag: "button1"+i.toString(),
                                    backgroundColor: _displayedColors[i]
                                )
                            )
                          ),
                          ]
                      ),*/
                      
                      //Buttons to enter answer
                      /*Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            for (int i=0;i<_itemsToRemember; i++) Container(
                              decoration: BoxDecoration(border: Border.all(color: _borderColors[i], width: borderWidth)),
                              child: SizedBox(
                                height: buttonHeight,
                                width: buttonWidth,
                                child:
                                FloatingActionButton(
                                    heroTag: "button2"+i.toString(),
                                    backgroundColor: _playerColors[i],
                                )
                            ),
                            )
                          ]
                      ),*/

                      //Buttons to memorize
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          for (int i=0; i<_itemsToRemember; i++) Container(
                            child: Padding(
                                padding: EdgeInsets.fromLTRB (5.0, 5.0, 5.0, 5.0),
                                child: Ink(
                                    decoration: ShapeDecoration(
                                        color: Colors.grey,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                            side: BorderSide(color: Colors.transparent, width:1))),
                                        child: IconButton(
                                          icon: Icon (_displayedIcons[i]),
                                          iconSize: 30,
                                          disabledColor: _displayedColors[i]
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
                                    padding: EdgeInsets.fromLTRB (5.0, 5.0, 5.0, 15.0),
                                    child: Ink(
                                      decoration: ShapeDecoration(
                                          color: Colors.grey,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                              side: BorderSide(color: _borderColors[i], width:2))),
                                              child: IconButton(
                                                icon: Icon (Icons.brightness_1),
                                                iconSize: 30,
                                                disabledColor: _playerColors[i]
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
                                child: FlatButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(15.0),
                                      side: BorderSide(color: Colors.black)),
                                  color: Colors.white,
                                  child: CustomPaint(painter: DrawCircle(_colors[i],12.0)),
                                  onPressed: () {
                                    if (_keyboardActive) _onTap(i);
                                    },

                                )
                                  )
                                ),
                            Container(
                              //decoration: BoxDecoration(color: Colors.white, border: Border.all(color:Colors.black, width:borderWidth)),
                              child: SizedBox(
                                height: keyboardButtonHeight,
                                width: keyboardButtonWidth,
                                    child: Ink(
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: new BorderRadius.circular(15.0),
                                          side: BorderSide(color: Colors.black))),
                                    child: IconButton(
                                      icon: Icon (Icons.arrow_back),
                                      iconSize: 30,
                                      onPressed: () {
                                        if (_keyboardActive){
                                        if (_currentButton>0) {
                                        _playerColors[_currentButton]=Colors.white70;
                                        _borderColors[_currentButton]=Colors.transparent;
                                        _currentButton--;
                                        _playerColors[_currentButton]=Colors.white70;
                                        _borderColors[_currentButton]=Colors.black;
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
                                    style: TextStyle(fontSize: 20)),
                                onPressed: () {
                                  _showStart = false;
                                  _start();
                                },
                                highlightColor: Colors.blue,
                                color: Colors.lightBlue,
                              )
                          )
                          else Row(
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
                                            side: BorderSide(color: Colors.transparent, width:1))),
                                          child: IconButton(
                                            icon: Icon (_icons[i]),
                                            iconSize: 30,
                                            disabledColor: Colors.black
                                          )
                                        ),
                                      )
                                    /*child: SizedBox(
                                      height: keyboardButtonHeight,
                                      width: keyboardButtonWidth,
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(15.0),
                                        side: BorderSide(color: Colors.black)),
                                        color: Colors.white,
                                        child: CustomPaint(painter: DrawCircle(_colors[i],12.0)),
                                          onPressed: () {
                                            if (_keyboardActive) _onTap(i);
                                          },
                                      )
                                    )*/
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

