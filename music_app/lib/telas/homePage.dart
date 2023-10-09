// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:music_app/telas/playerDeMusicas.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> paginaInicial = [];
  int contadorMenu = 0;

  @override
  void initState() {
    super.initState();
    PlayerControlador.instance;
    PlayerControlador.instance.obterPaginaInicial();
    PlayerControlador.instance.addListener(() {
      setState(() {
        paginaInicial = PlayerControlador.instance.paginaInicial;
      });
    });
  }

  void menuBaixo(int index) {
    setState(() {
      contadorMenu = index;
    });

    switch (index) {
      case 0:
        mostrarModal('Já estamos na pagina Inicial');
        break;
      case 1:
        PlayerControlador.instance;
        PlayerControlador.instance.obterMusicas('aleatorias');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyHomePage(pessoa: 'aleatorias'),
          ),
        );

        break;
      case 2:
        mostrarModal(' Em construção ...');
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appControladorTema.istance.corTema2,
            appControladorTema.istance.corTema1,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
        body: SingleChildScrollView(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 100.0,
                bottom: 20.0,
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      PlayerControlador.instance.stopMusic();
                      PlayerControlador.instance.limparMusicas();
                      PlayerControlador.instance.obterMusicas('aleatorias');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                            pessoa: 'aleatorias',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/imagens/musicDefault.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.65,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: Colors.black.withOpacity(0.8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Aleatórias',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '100 musicas aleatórias',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
                                const Icon(
                                  Icons.play_circle,
                                  color: Colors.deepPurple,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('generos',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Arraste para ver mais',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.27,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: paginaInicial.isNotEmpty
                            ? paginaInicial[1].length
                            : 0,
                        itemBuilder: (context, index) {
                          final genero = paginaInicial.isNotEmpty
                              ? paginaInicial[1].keys.toList()[index]
                              : 'desconhecido';

                          final quantidade = paginaInicial.isNotEmpty
                              ? paginaInicial[1][genero]
                              : 0;
                          return InkWell(
                            onTap: () {
                              PlayerControlador.instance.stopMusic();
                              PlayerControlador.instance.limparMusicas();

                              PlayerControlador.instance.obterMusicas(genero);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(
                                    pessoa: '$genero',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      image: DecorationImage(
                                        image: AssetImage(
                                          'assets/imagens/$genero.jpg',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      color: Colors.black.withOpacity(0.8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                genero,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .copyWith(
                                                      color: Colors.deepPurple,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            Text(
                                              '$quantidade  musicas',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall!
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const Icon(
                                          Icons.play_circle,
                                          color: Colors.deepPurple,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Artistas',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('Suba para ver mais',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        paginaInicial.isNotEmpty ? paginaInicial[2].length : 0,
                    itemBuilder: ((context, index) {
                      final artista = paginaInicial.isNotEmpty
                          ? paginaInicial[2].keys.toList()[index]
                          : const CircularProgressIndicator();
                      final quantidade = paginaInicial[2][artista];
                      return InkWell(
                        onTap: () {
                          PlayerControlador.instance.stopMusic();
                          PlayerControlador.instance.limparMusicas();

                          PlayerControlador.instance.obterMusicas(artista);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyHomePage(
                                pessoa: '$artista',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 75,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade800.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15.0),
                                child: Image.asset(
                                  'assets/imagens/musicDefault.jpg',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      artista,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '$quantidade musicas',
                                      maxLines: 2,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.play_circle,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
