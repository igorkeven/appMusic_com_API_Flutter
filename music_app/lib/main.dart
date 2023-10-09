import 'dart:typed_data'; // para Uint8List
import 'dart:io'; // para File

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:http/http.dart' as http;
import 'package:music_app/telas/homePage.dart';
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
    PlayerControlador.instance;
    PlayerControlador.instance.obterPaginaInicial();
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

// ignore: must_be_immutable
class PlayerControlador extends ChangeNotifier {
  String currentSong = ''; // Armazene o ID da música atual aqui
  List<dynamic> musicas = [];
  List<dynamic> paginaInicial = [];
  int currentIndex = 0;
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(prefix: 'assets/musicas/');
  PlayerState playerState = PlayerState.paused;
  Uint8List? albumArt;

  static PlayerControlador instance = PlayerControlador();

  Future<void> obterMusicas(pessoa) async {
    final response = await http
        .get(Uri.parse('http://seuIP/api/musicas/$pessoa'));
    if (response.statusCode == 200) {
      musicas = json.decode(response.body);

      notifyListeners();
    }
  }

  Future<void> obterPaginaInicial() async {
    final response = await http
        .get(Uri.parse('http://seuIP/api/musicas/paginaInicial'));
    if (response.statusCode == 200) {
      paginaInicial = json.decode(response.body);

      notifyListeners();
    }
  }

  void limparMusicas(){
    musicas = [];
    notifyListeners();
  }

  void setCurrentSong(String songId) {
    currentSong = songId;
    notifyListeners();
  }

  void playNovaMusica(url, indexMusica) async {
    audioPlayer.play(UrlSource(url));
    currentIndex = indexMusica;
    notifyListeners();
  }

  void playMusic() async {
    String url = musicas.isNotEmpty ? musicas[currentIndex]['url'] : '';
    audioPlayer.play(UrlSource(url));
    isPlaying = true;
    final metadata =
        await MetadataRetriever.fromFile(File(musicas[currentIndex]['url']!));
    albumArt = metadata.albumArt;

    
    notifyListeners();
  }

  void pauseMusic() {
    audioPlayer.pause();

    isPlaying = false;
    notifyListeners();
  }

  void resume() {
    audioPlayer.resume();
    isPlaying = true;
    notifyListeners();
  }

  void stopMusic() {
    audioPlayer.stop();

    isPlaying = false;
    notifyListeners();
  }

  // logica paraq avançar e voltar a musica se playNextOrPrevious(true) passa a musica se (false) volta
  void playNextOrPrevious(bool isNext) {
    if (isNext) {
      if (currentIndex < musicas.length - 1) {
        currentIndex++;
        notifyListeners();
      }
    } else {
      if (currentIndex > 0) {
        currentIndex--;
        notifyListeners();
      }
    }
    playMusic();
    notifyListeners();
  }

  void onSwipeUp() {
    playNextOrPrevious(true);
  }

  void onSwipeDown() {
    playNextOrPrevious(false);
  }
}

// ignore: camel_case_types
class appControladorTema extends ChangeNotifier {
  static appControladorTema istance = appControladorTema();

  bool temadark = false;
  Color corTema1 = Colors.blue.shade200.withOpacity(0.9);
  Color corTema2 = Colors.blue.shade600;
  Color corBotoes = Colors.black;
  Color corAzulBlack = Colors.blueAccent;
  mudarTema() {
    temadark = !temadark;
    corTema1 = temadark
        ? const Color.fromARGB(255, 92, 89, 89).withOpacity(0.9)
        : Colors.blue.shade200.withOpacity(0.9);
    corTema2 = temadark ? Colors.black : Colors.blue.shade600;
    corBotoes = temadark ? Colors.white : Colors.black;
    corAzulBlack =
        temadark ? const Color.fromARGB(255, 0, 50, 90) : Colors.blueAccent;
    notifyListeners();
  }
}

// ignore: camel_case_types
class classeTema extends StatelessWidget {
  const classeTema({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch(
        value: appControladorTema.istance.temadark,
        onChanged: (value) {
          appControladorTema.istance.mudarTema();
        });
  }
}
