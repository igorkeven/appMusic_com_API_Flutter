import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'package:music_app/main.dart';

class ListaDeMusicas extends StatefulWidget {
  final String pessoa;
  final bool isPlaying;
  final String currentSongUrl;
  const ListaDeMusicas(
      {required this.currentSongUrl,
      required this.isPlaying,
      required this.pessoa,
      super.key});

  @override
  State<ListaDeMusicas> createState() => _ListaDeMusicasState();
}

class _ListaDeMusicasState extends State<ListaDeMusicas> {
  List<dynamic> musicas = [];
  bool isPlaying = false;
  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState playerState = PlayerState.paused;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    musicas = PlayerControlador.instance.musicas;
    isPlaying = PlayerControlador.instance.isPlaying;
    currentIndex = PlayerControlador.instance.currentIndex;
  }

  @override
  void dispose() {
    super.dispose();
  }

// FUNÇÃO PARA DAR PLAY E PAUSE NA LISTA DE MUSICA
  void togglePlayPause(bool musicUrl, String musicaLocal, int index) {
    if (musicUrl) {
      // Se a música já estiver tocando, pause
      if (isPlaying) {
        print('pause da lista');
        PlayerControlador.instance.pauseMusic();
        isPlaying = false;
      } else {
        // Se a música estiver pausada, retome a reprodução
        PlayerControlador.instance.playMusic();
        print('play da lista');
        isPlaying = true;
      }
    } else {
      // Se a música for diferente da que está tocando, inicie a nova música
      PlayerControlador.instance.playNovaMusica(musicaLocal, index);
      print('play de outra musica');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nome = widget.pessoa;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Lista de Músicas do $nome'),
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('assets/imagens/musicDefault.jpg'),
            ),
            accountEmail: null,
          ),
          if (musicas.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: musicas.length,
                itemBuilder: (context, index) {
                  

                  final musicUrl = index == currentIndex;
                  
                  return ListTile(
                    leading: musicUrl & isPlaying
                        ? const Icon(Icons.pause, color: Colors.green) 
                        : const Icon(Icons.play_arrow),
                    onTap: () {
                      setState(() {
                        togglePlayPause(musicUrl, musicas[index]['url'], index);
                      });
                      
                    },
                    title: Text(
                      musicas[index]['titulo'],
                      style: TextStyle(
                        color: musicUrl
                            ? Colors.green
                            : Colors.black, // Define a cor do texto
                        fontWeight: musicUrl
                            ? FontWeight.bold
                            : FontWeight.normal, // Define o estilo do texto
                      ),
                    ),
                    subtitle: Text(musicas[index]['artista']),

                    // Adicione outras informações da música aqui
                  );
                },
              ),
            )
          else
            const Center(
              child: Text('Carregando Musicas aguarde'),
            ),
        ],
      ),
    );
  }
}
