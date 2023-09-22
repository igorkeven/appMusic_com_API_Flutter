


from flask import Flask, send_file,make_response, jsonify, request, render_template, redirect, flash
import json
import os


app = Flask(__name__)
app.config['SECRET_KEY'] = "IGORKEVEN-M-S"



@app.route('/')
def pagina():
    return render_template('musica.html')


# rota e função para salvar uma musica no servidor atraves do html
@app.route('/salvar_nova_musica', methods=['POST'])
def salvarMusica():
    usuario = request.form.get('usuario')
    titulo = request.form.get('titulo')
    artista = request.form.get('artista')
    musica = request.files.get('musica')
    
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
        "url": f"http://SEU_IP_AQUI/api/reproduzir/{id}",
        "local": f"static/musicas/{nome_arquivo}"

    }

    musicas.append(nova_musica)

    with open('musicas.json', 'w') as musicas_gravar:
        json.dump(musicas, musicas_gravar,  indent=4)

    
    flash('Arquivo salvo com sucesso!')
    return redirect('/')


# rota e função para reproduzir a musica escolhida pelo app
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

# rota e função para escolher a lista de musicas especificas do usuario e envia-la ao app
@app.route('/api/musicas/<string:nomeUsuario>', methods=['GET'])
def obter_musicas(nomeUsuario):
    musicas_usuario = []
    
    
    with open('musicas.json') as musicas_json:
        musicas = json.load(musicas_json) 
    # Retorna as músicas em formato JSON
    

    for musica in musicas:
        if musica['usuario'] == nomeUsuario:
            musicas_usuario.append(musica)

    return jsonify(musicas_usuario) 



if __name__ == '__main__':
    # lembre de apagar o host='0.0.0.0' e o debug quando subir a api, para ter mais segurança
    app.run(debug=True, host='0.0.0.0')
