import 'package:flutter/material.dart';
import 'package:music_app/main.dart';
import 'package:music_app/telas/playerDeMusicas.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// AQUI PODE CRIAR UMA PAGINA DE LOGIN SE QUISER , A IDEIA É PASSAR UM NOME PARA IDENTIFICAR O USUARIO
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Ação quando o primeiro botão é pressionado
                PlayerControlador.instance;
                PlayerControlador.instance.obterMusicas('igor');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pessoa: 'igor',
                      musicas: PlayerControlador.instance.musicas,
                    ),
                  ),
                );
              },
              child: Text('Igor Keven'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                // Ação quando o segundo botão é pressionado
                    PlayerControlador.instance;
                PlayerControlador.instance.obterMusicas('raiza');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pessoa: 'raiza',
                      musicas: PlayerControlador.instance.musicas,
                    ),
                  ),
                );
              },
              child: Text('Raiza Emanoelle'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                // Ação quando o terceiro botão é pressionado
                    PlayerControlador.instance;
                PlayerControlador.instance.obterMusicas('joao');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pessoa: 'joao',
                      musicas: PlayerControlador.instance.musicas,
                    ),
                  ),
                );
              },
              child: Text('João Keven'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                // Ação quando o quarto botão é pressionado
                    PlayerControlador.instance;
                PlayerControlador.instance.obterMusicas('gabriel');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pessoa: 'gabriel',
                      musicas: PlayerControlador.instance.musicas,
                    ),
                  ),
                );
              },
              child: Text('Gabriel Keven'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                // Ação quando o quinto botão é pressionado
                    PlayerControlador.instance;
                PlayerControlador.instance.obterMusicas('bia');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pessoa: 'bia',
                      musicas: PlayerControlador.instance.musicas,
                    ),
                  ),
                );
              },
              child: Text('bia akemi'),
            ),
            SizedBox(
              height: 25,
            ),
            ElevatedButton(
              onPressed: () {
                // Ação quando o sexto botão é pressionado
                    PlayerControlador.instance;
                PlayerControlador.instance.obterMusicas('joel');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      pessoa: 'joel',
                      musicas: PlayerControlador.instance.musicas,
                    ),
                  ),
                );
              },
              child: Text('Joel Moraes'),
            ),
          ],
        ),
      ),
    );
  }
}
