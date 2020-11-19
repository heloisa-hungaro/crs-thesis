import 'package:tuple/tuple.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:core';
import 'dart:convert';
import './pageenviardados.dart';

// ---------------------------------------------------------------------------------------------- //

// SERVIDOR

class Servidor {
  String ip = '';
  String porta = '';
  ServerSocket serverSocket;
  Map<String, Tuple2> receivedAnswers =
      {}; // key: emailAluno ; value: (nomeAluno, alternativa escolhida)
  int numRespostas = 0;
  int numRespAnon = 0;
  EnviarDadosState parent;

  Future<bool> startServer() async {
    try {
      serverSocket = await ServerSocket.bind(ip, int.parse(porta));
      print('connected');
      return true;
    } catch (e) {
      print('can´t start server: $e');
      return false;
    }
  }

  Future<void> closeServer() async {
    try {
      await serverSocket.close();
      print('server closed');
    } catch (e) {
      print('can´t close server');
    }
  }

  Future<String> _getStrSend(nome, turma, data, hora, imgW, imgH, correta,
      mostraResp, posAlt, fileName, dados) async {
    String sizeDados = dados.length.toString();
    String auxW = imgW.toStringAsFixed(3);
    String auxH = imgH.toStringAsFixed(3);
    String numAlt = posAlt.length.toString();
    int mostra;
    if (mostraResp) {
      mostra = 1;
    } else {
      mostra = 0;
    }

    String str =
        '$nome§$turma§$data§$hora§$auxW§$auxH§$numAlt§$correta§$mostra';

    for (var i = 0; i < posAlt.length; i++) {
      auxW = posAlt[i].item1.toStringAsFixed(3);
      auxH = posAlt[i].item2.toStringAsFixed(3);
      str = '$str§$auxW§$auxH';
    }

    str = '$str§$fileName§$sizeDados§X_FiG%SeP_X§$dados';

    return str;
  }

  Future<void> startListening(nome, turma, data, hora, imgW, imgH, correta,
      mostraResp, posAlt, fileQuestao) async {
    var img = File(fileQuestao.path);
    String fileName = basename(img.path);

    var dadosBytes = await img.readAsBytes();
    var dados = Base64Codec().encode(dadosBytes);

    List splited;
    String strSend = await _getStrSend(nome, turma, data, hora, imgW, imgH,
        correta, mostraResp, posAlt, fileName, dados);

    receivedAnswers.clear();
    numRespostas = 0;
    try {
      await for (var socket in serverSocket) {
        print('request in server');
        socket.write(strSend);
        socket.transform(utf8.decoder).listen((String received) {
          splited = received.split("§");

          String nomeAluno;
          String emailAluno;
          String respostaAluno;

          emailAluno = splited[0];
          nomeAluno = splited[1];
          respostaAluno = splited[2];

          if (!receivedAnswers.containsKey(emailAluno)) {
            // only add answer once for each aluno
            receivedAnswers[emailAluno] =
                Tuple2<String, int>(nomeAluno, int.parse(respostaAluno));
            numRespostas++;
            if (nomeAluno == 'Anônimo') {
              numRespAnon++;
            }
          }
          parent.update();

          socket.close();
        });
      }
    } catch (e) {
      parent.erroSocket();
      print(e);
    }
  }
}
