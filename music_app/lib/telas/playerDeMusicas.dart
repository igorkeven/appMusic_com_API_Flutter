import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_app/main.dart';
import 'package:music_app/telas/listaMusicas.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'dart:typed_data'; // para Uint8List
import 'dart:io'; // para File

class MyHomePage extends StatefulWidget {
  final String pessoa;
  final List<dynamic> musicas;

  const MyHomePage({required this.pessoa, required this.musicas, Key? key})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> musicas = [];
  int currentIndex = 0;
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache = AudioCache(prefix: 'assets/musicas/');
  PlayerState playerState = PlayerState.paused;
  String duration = '0';
  String position = '0';
  double sliderValue = 0;
  Uint8List? albumArt;

  @override
  void initState() {
    super.initState();
    
    // Use o Provider para definir a música atual
    PlayerControlador.instance.addListener(() {
      setState(() {
        musicas = PlayerControlador.instance.musicas;
        currentIndex = PlayerControlador.instance.currentIndex;
        isPlaying = PlayerControlador.instance.isPlaying;
        duration = PlayerControlador.instance.duration;
        position = PlayerControlador.instance.position;
        sliderValue = PlayerControlador.instance.sliderValue;
        audioPlayer = PlayerControlador.instance.audioPlayer;
        imagem(musicas[currentIndex]['url']);
        audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
          setState(() => playerState = s);
        });

        audioPlayer.onDurationChanged.listen((Duration d) {
          setState(() {
            final minutes = (d.inMinutes).toString().padLeft(2, '0');
            final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
            duration = '$minutes:$seconds';
          });
        });

        audioPlayer.onPositionChanged.listen((Duration p) {
          setState(() {
            final minutes = (p.inMinutes).toString().padLeft(2, '0');
            final seconds = (p.inSeconds % 60).toString().padLeft(2, '0');
            position = '$minutes:$seconds';
          });
        });

        audioPlayer.onPlayerComplete.listen((event) {
          if (currentIndex < musicas.length - 1) {
            // Há uma próxima música disponível, então avance para ela
            setState(() {
              PlayerControlador.instance.playNextOrPrevious(true);
            });
          } else {
            // Não há mais músicas disponíveis, você pode decidir o que fazer aqui
            PlayerControlador.instance.stopMusic();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.dispose();
    audioPlayer.release();
  }

  Future<void> obterMusicas(pessoa) async {
    final response = await http
        .get(Uri.parse('http://SEU_IP_AQUI/api/musicas/$pessoa'));
    if (response.statusCode == 200) {
      setState(() {
        musicas = json.decode(response.body);
      });
    }
  }

// FUNÇÃO PARA TRANSFORMAR O TEMPO INTEIRO PARA STRING
  double stringToDoubleDuration(String durationString) {
    List<String> parts = durationString.split(':');
    if (parts.length == 2) {
      int minutes = int.parse(parts[0]);
      int seconds = int.parse(parts[1]);
      return (minutes * 60 + seconds).toDouble();
    } else {
      return 0.0;
    }
  }

// FUNÇÃO PARA PEGAR A IMAGEM DO METADATA DA MUSICA
  void imagem(String? file) async {
    final metadata = await MetadataRetriever.fromFile(File(file!));
    albumArt = metadata.albumArt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keven Music'),
        actions: [
          Row(
            children: [
              appControladorTema.istance.temadark
                  ? const Icon(Icons.brightness_2) // Ícone para o modo escuro
                  : const Icon(Icons.wb_sunny), // Ícone para o modo claro,
              Switch(
                  value: appControladorTema.istance.temadark,
                  onChanged: (value) {
                    setState(() {
                      appControladorTema.istance.mudarTema();
                    });
                  }),
            ],
          )
        ],
      ),
      drawer: ListaDeMusicas(
        pessoa: widget.pessoa,
        currentSongUrl: musicas.isNotEmpty ? musicas[currentIndex]['url'] : '',
        isPlaying: isPlaying,
      ),
      body: Center(
        child: GestureDetector(
          onVerticalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              PlayerControlador.instance.onSwipeUp();
            } else if (details.primaryVelocity! > 0) {
              PlayerControlador.instance.onSwipeDown();
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FractionallySizedBox(
                widthFactor:
                    0.8, // Define a largura como 80% do espaço disponível
                child: musicas.isNotEmpty && albumArt != null ? Image.memory(albumArt!, fit: BoxFit.contain,): 
                 Image.asset('assets/imagens/musicDefault.jpg',
                  fit: BoxFit.contain, 
                ),
              ),
              const SizedBox(height: 20),
              Text(
                musicas.isNotEmpty
                    ? musicas[currentIndex]['titulo']
                    : 'sem titulo',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                musicas.isNotEmpty
                    ? musicas[currentIndex]['artista']
                    : 'artista desconhecido',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Slider(
                value: sliderValue,
                min: 0,
                max: stringToDoubleDuration(duration),
                onChanged: (value) {
                  double newPosition = value;
                  if (newPosition <= stringToDoubleDuration(duration) &&
                      newPosition >= 0) {
                    setState(() {
                      sliderValue = newPosition;
                      position = '$newPosition';
                    });
                    audioPlayer.seek(Duration(seconds: newPosition.toInt()));
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Tempo decorrido
                  Text(
                    position,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  // Tempo restante
                  Text(
                    duration,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () => PlayerControlador.instance
                          .playNextOrPrevious(false), // Retroceder
                      iconSize: 48,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow),
                      onPressed: isPlaying
                          ? PlayerControlador.instance.pauseMusic
                          : PlayerControlador.instance.playMusic, //playMusic,
                      iconSize: 64,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => PlayerControlador.instance
                          .playNextOrPrevious(true), // Avançar
                      iconSize: 48,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
