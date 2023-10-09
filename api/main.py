


from flask import Flask, send_file,make_response, jsonify, request, render_template, redirect, flash
import json
import os


app = Flask(__name__)
app.config['SECRET_KEY'] = "IGORKEVEN-M-S"



@app.route('/')
def pagina():
    return render_template('musica.html')



@app.route('/salvar_nova_musica', methods=['POST'])
def salvarMusica():
    usuario = request.form.get('usuario')
    titulo = request.form.get('titulo')
    artista = request.form.get('artista')
    musica = request.files.get('musica')
    genero = request.form.get('genero')
    
    nome_arquivo = f"{titulo}.{musica.filename.split('.')[-1] }"
    musica.save(os.path.join('static/musicas/', nome_arquivo))
    with open('musicas.json') as musicas_json:
        musicas = json.load(musicas_json)

    
        id = len(musicas) + 1


    nova_musica = {
        "id": id,
        "usuario": usuario,
        "titulo": titulo,
        "artista": artista,
        "genero": genero,
        "url": f"http://seuIP/api/reproduzir/{id}",
        "local": f"static/musicas/{nome_arquivo}"

    }

    musicas.append(nova_musica)

    with open('musicas.json', 'w') as musicas_gravar:
        json.dump(musicas, musicas_gravar,  indent=4)

    
    flash('Arquivo salvo com sucesso!')
    return redirect('/')



@app.route('/api/reproduzir/<int:musica_id>', methods=['GET'])
def reproduzir_musica( musica_id):
    musicas = {}
    with open(f'musicas.json') as musicas_json:
        musicas = json.load(musicas_json)

    musica_escolhida = next((musica for musica in musicas if musica['id'] == musica_id), None)

    if musica_escolhida:
        caminho_arquivo = musica_escolhida['local']
        response = make_response(send_file(caminho_arquivo))
        response.headers['content-type'] = 'audio/mpeg'
        return response

    return "Música não encontrada", 404


@app.route('/api/musicas/<string:nomeUsuario>', methods=['GET'])
def obter_musicas(nomeUsuario):
    musicas_usuario = []
    
    
    with open('musicas.json') as musicas_json:
        musicas = json.load(musicas_json) 
    # Retorna as músicas em formato JSON
    
    as100aleatorias = []
    for musica in musicas:
        if musica['usuario'] == nomeUsuario:
            musicas_usuario.append(musica)
        if nomeUsuario == 'aleatorias' and musica['usuario'] != 'kevenaom':
            as100aleatorias.append(musica)
        if nomeUsuario == musica['genero'] and musica['usuario'] != 'kevenaom':
            musicas_usuario.append(musica)
        if nomeUsuario == musica['artista'] and musica['usuario'] != 'kevenaom':
            musicas_usuario.append(musica)

   # Embaralhe a lista de músicas aleatórias
    random.shuffle(as100aleatorias)
    
    # Obtenha as 100 primeiras músicas aleatórias
    as100aleatorias = as100aleatorias[:100]

    if nomeUsuario == 'aleatorias':
        return jsonify(as100aleatorias)
    else:
        return jsonify(musicas_usuario)

@app.route('/api/musicas/paginaInicial', methods=['GET'])
def PaginaAppInicial():
    generos = {}
    artistas = {}
    paginaInicial = []
    todasMusicas = 0

    with open('musicas.json') as musicas_json:
        musicas = json.load(musicas_json) 

    for musica in musicas:
        if musica['usuario'] == 'kevenaom':
            continue
        if musica['usuario'] != 'kevenaom':
            todasMusicas +=1
        if musica['genero'] not in generos:
           generos[musica['genero']] =  1
        else:
            generos[musica['genero']] += 1

        if musica['artista'] not in artistas:
            artistas[musica['artista']] = 1
        else:
            artistas[musica['artista']] += 1

    # Embaralhe a lista de todas as músicas
    

    paginaInicial.append(todasMusicas)
    paginaInicial.append(generos)
    paginaInicial.append(artistas)

    return jsonify(paginaInicial)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
