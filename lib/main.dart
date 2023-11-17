import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'musique.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      title: 'Musique',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Musique'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;
   List<Musique> maListeDeMusiques = [
    new Musique('Theme Swift', 'Codabee', 'assets/un.jpg', "https:\/\/cdns-preview-c.dzcdn.net\/stream\/c-c7825b6aaa6f716804167655496be48a-3.mp3"),
    new Musique('Theme Flutter', 'Codabee', 'assets/deux.jpg', "https://cdns-preview-1.dzcdn.net//stream//c-19905a61b5e41e9cc48c3ce5d05fd311-5.mp3"),

  ];
  late Musique maMusiqueActuelle;
  Duration position=new Duration(seconds: 0);
  late AudioPlayer audioPlayer;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
   late Future< Duration?> duree;
   PlayerState statut = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];
    configurationAudioPlayer();
    
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title,style: TextStyle(color: Colors.white),),
        
      ),
       backgroundColor: Colors.grey[800],
      body: Center(
        
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusiqueActuelle.titre, 1.5),
            texteAvecStyle(maMusiqueActuelle.artiste, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                bouton((statut == PlayerState.playing) ?Icons.pause: Icons.play_arrow, 45.0,(statut == PlayerState.playing) ? ActionMusic.pause: ActionMusic.play),
                bouton(Icons.fast_forward, 30.0, ActionMusic.forward)
              ],
            ),
             new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle('0:0', 0.8),
                texteAvecStyle("0:22", 0.8)
              ],
            ),Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                 setState(() {
                  Duration duration=new Duration(seconds: d.toInt());
                    
                    audioPlayer.seek(duration);
                  });
                })
            ], 
            
        ),
      ),
      
    );
  }

  Text texteAvecStyle(String data, double scale) {
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
      iconSize: taille,
        color: Colors.white,
        icon: new Icon(icone),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
            play();
          
              break;
            case ActionMusic.pause:
             pause();
              break;
            case ActionMusic.forward:
             forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
          }
        },
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onPositionChanged.listen(
        (pos) => setState(() => position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
     if (state == PlayerState.playing) {
        setState(() {
          duree = audioPlayer.getDuration();
        });
      } else if (state == PlayerState.stopped) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    },
    onError: (message) {
      print('erreur: $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0) as Future<Duration?>;
        position = new  Duration(seconds: 0);
      });
    }
    );

    
  }

  Future play() async {
    
    await audioPlayer.play(UrlSource(maMusiqueActuelle.urlSong));
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
    if (index == maListeDeMusiques.length - 1) {
      index = 0;
    } else {
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }
  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek(new Duration(seconds: 0));
    } else {
      if (index == 0) {
        index = maListeDeMusiques.length - 1;
      } else {
        index--;
      }
      maMusiqueActuelle = maListeDeMusiques[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}

enum PlayerState {
  playing,
  stopped,
  paused
}
