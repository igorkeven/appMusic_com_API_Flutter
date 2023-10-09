// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_app/main.dart';
import 'package:music_app/telas/homePage.dart';
import 'package:music_app/telas/listaMusicas.dart';
import 'dart:typed_data'; // para Uint8List

class MyHomePage extends StatefulWidget {
  final String pessoa;

  const MyHomePage({required this.pessoa, Key? key}) : super(key: key);

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
  int contadorMenu = 0;

  @override
  void initState() {
    super.initState();

    // Use o Provider para definir a música atual
    PlayerControlador.instance.addListener(() {
      setState(() {
        musicas = PlayerControlador.instance.musicas;
        currentIndex = PlayerControlador.instance.currentIndex;
        isPlaying = PlayerControlador.instance.isPlaying;
        audioPlayer = PlayerControlador.instance.audioPlayer;
        albumArt = PlayerControlador.instance.albumArt;
        sliderValue = stringToDoubleDuration(position);
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
            sliderValue = stringToDoubleDuration(position);
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

  void menuBaixo(int index) {
    setState(() {
      contadorMenu = index;
    });

    switch (index) {
      case 0:
        PlayerControlador.instance;
        PlayerControlador.instance.obterPaginaInicial();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );

        break;
      case 1:
        mostrarModal('Já estamos no player');
        break;
      case 2:
        mostrarModal('Em construção ...');
        break;
    }
  }

  void mostrarModal(String mensagem) {
    final snackBar = SnackBar(
      content: Text(
        mensagem,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 20), // Personalize o estilo do texto aqui
      ),
      backgroundColor:
          Colors.black.withOpacity(.6), // Personalize a cor de fundo aqui
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior
          .floating, // Faz o SnackBar aparecer flutuando acima de todos os outros widgets
      shape: RoundedRectangleBorder(
        // Personalize a forma aqui
        borderRadius: BorderRadius.circular(25.0),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    if (value) {
                      mostrarModal('tema escuro ativado');
                    } else {
                      mostrarModal('tema claro ativado');
                    }
                  }),
            ],
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: appControladorTema.istance.corAzulBlack,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Play',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: contadorMenu,
        onTap: menuBaixo,
      ),
      drawer: ListaDeMusicas(
        pessoa: widget.pessoa,
        currentSongUrl: musicas.isNotEmpty ? musicas[currentIndex]['url'] : '',
        isPlaying: isPlaying,
      ),
      body: Stack(fit: StackFit.expand, children: [
        musicas.isNotEmpty && albumArt != null
            ? Image.memory(
                albumArt!,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/imagens/musicDefault.jpg',
                fit: BoxFit.cover,
              ),
        GestureDetector(
          onVerticalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              PlayerControlador.instance.onSwipeUp();
            } else if (details.primaryVelocity! > 0) {
              PlayerControlador.instance.onSwipeDown();
            }
          },
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.5),
                    Colors.white.withOpacity(0.0),
                  ],
                  stops: const [
                    0.0,
                    0.4,
                    0.6
                  ]).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    appControladorTema.istance.corTema1,
                    appControladorTema.istance.corTema2,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 50.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      musicas.isNotEmpty
                          ? musicas[currentIndex]['titulo']
                          : 'sem titulo',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      musicas.isNotEmpty
                          ? musicas[currentIndex]['artista']
                          : 'artista desconhecido',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors
                            .deepPurple, // Cor da linha quando o valor é maior que o valor mínimo
                        inactiveTrackColor: Colors
                            .grey, // Cor da linha quando o valor é menor que o valor mínimo
                        thumbColor: appControladorTema
                            .istance.corBotoes, // Cor do círculo deslizante
                        overlayColor: Colors.deepPurple.withOpacity(
                            0.4), // Cor da sobreposição ao arrastar o círculo deslizante
                      ),
                      child: Slider(
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
                            audioPlayer
                                .seek(Duration(seconds: newPosition.toInt()));
                          }
                        },
                      ),
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
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () => PlayerControlador.instance
                              .playNextOrPrevious(false), // Retroceder
                          iconSize: 48,
                          color: appControladorTema.istance.corBotoes,
                        ),
                        IconButton(
                          icon: isPlaying
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                          onPressed: isPlaying
                              ? PlayerControlador.instance.pauseMusic
                              : PlayerControlador.instance.playMusic,
                          iconSize: 64,
                          color: appControladorTema.istance.corBotoes,
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          onPressed: () => PlayerControlador.instance
                              .playNextOrPrevious(true), // Avançar
                          iconSize: 48,
                          color: appControladorTema.istance.corBotoes,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
