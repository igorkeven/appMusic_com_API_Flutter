import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/telas/homePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';


void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PlayerControlador(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: appControladorTema.istance,
        builder: (context, child) {
          return MaterialApp(
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: appControladorTema.istance.temadark
                  ? Brightness.dark
                  : Brightness.light,
            ),
            debugShowCheckedModeBanner: false,
            title: 'Keven Musicas',
            home: const HomePage(),
          );
        });
  }
}
// CONTROLADOR DE tODO APLICATIVO PARA TODAS AS TELAS
// ignore: must_be_immutable
class PlayerControlador extends ChangeNotifier {
  String currentSong = ''; // Armazene o ID da música atual aqui
  List<dynamic> musicas = [];
  int currentIndex = 0;
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(prefix: 'assets/musicas/');
  PlayerState playerState = PlayerState.paused;
  String duration = '0';
  String position = '0';
  double sliderValue = 0;

  static PlayerControlador instance = PlayerControlador();

// função para obter a lista de musicas do usuario especifico atraves da api
  Future<void> obterMusicas(pessoa) async {
    final response = await http
        .get(Uri.parse('http://SEU_IP_AQUI/api/musicas/$pessoa'));
    if (response.statusCode == 200) {
      musicas = json.decode(response.body);
      notifyListeners();
    }
  }

  void setCurrentSong(String songId) {
    currentSong = songId;
    notifyListeners();
  }

// função para dar play em uma musica especifica atraves da lista de musicas
  void playNovaMusica(url, indexMusica) async {
    audioPlayer.play(UrlSource(url));
    currentIndex = indexMusica;
    notifyListeners();
  }

// função para dar play na musica 
  void playMusic() async {
    String url = await musicas.isNotEmpty ? musicas[currentIndex]['url'] : '';
    audioPlayer.play(UrlSource(url));

    isPlaying = true;
    notifyListeners();
  }
// função parapausar a musica
  void pauseMusic() {
    audioPlayer.pause();

    isPlaying = false;
    notifyListeners();
  }
//função para retomar a musica
  void resume() {
    audioPlayer.resume();
    isPlaying = true;
    notifyListeners();
  }
// função para parar definitivamente a musica
  void stopMusic() {
    audioPlayer.stop();

    isPlaying = false;
    notifyListeners();
    // Lógica para parar a reprodução da música atual usando audioplayers
  }

    // logica paraq avançar e voltar a musica se playNextOrPrevious(true) passa a musica se (false) volta
  void playNextOrPrevious(bool isNext) {
    if (isNext) {
      if (currentIndex < musicas.length - 1) {
        currentIndex++;
        position = '0';
        notifyListeners();
      }
    } else {
      if (currentIndex > 0) {
        currentIndex--;
        position = '0';
        notifyListeners();
      }
    }
    
    playMusic();
    notifyListeners();
  }

//função para mudar a musica ao arrastar o dedo na tela
  void onSwipeUp() {
    playNextOrPrevious(true);
  }

  void onSwipeDown() {
    playNextOrPrevious(false);
  }




}

//controlador do tema escuro e claro em todo app
class appControladorTema extends ChangeNotifier {
  static appControladorTema istance = appControladorTema();

  bool temadark = false;
  mudarTema() {
    temadark = !temadark;
    notifyListeners();
  }
}

