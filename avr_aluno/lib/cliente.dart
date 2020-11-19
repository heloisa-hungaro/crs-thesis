import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:tuple/tuple.dart';
import 'package:path_provider/path_provider.dart';

// ---------------------------------------------------------------------------------------------- //

// SERVIDOR

class Cliente {
  String ip = '';
  String porta = '';
  Socket clientSocket;
  Map<String, Tuple2> receivedAnswers =
      {}; // key: emailAluno ; value: (nomeAluno, alternativa escolhida)
  int numRespostas = 0;

  Future<bool> startSocket() async {
    try {
      clientSocket = await Socket.connect(ip, int.parse(porta))
          .timeout(const Duration(seconds: 8));
      print('connected');
      return true;
    } catch (e) {
      print('can´t connect to server: $e');
      return false;
    }
  }

  Future<void> closeSocket() async {
    try {
      await clientSocket.close();
      print('client closed');
    } catch (e) {
      print('can´t close client');
    }
  }

  Future<void> _createIfDoesntExists(filePath) async {
    File file = File("$filePath");
    final existsFile = await file.exists();
    if (!existsFile) {
      await file.create();
    }
  }

  Future<List> socketListen() async {
    String concatImg;
    List splited;
    int sizeDados;
    int countReceived;
    bool firstTime = true;
    Directory directory = await getApplicationDocumentsDirectory();

    firstTime = true;
    try {
      await for (String received in clientSocket.transform(utf8.decoder)) {
        if (firstTime) {
          countReceived = 0;
          List separateImg = received.split("§X_FiG%SeP_X§");
          // dados recebidos exceto imagem salvos em splited !
          splited = separateImg[0].split("§");
          sizeDados = int.parse(splited[splited.length - 1]);
          concatImg = separateImg[1];
          countReceived += separateImg[1].length;
          firstTime = false;
        } else {
          // not first time!
          concatImg = concatImg + received;
          countReceived += received.length;
        }
        if (countReceived == sizeDados) {
          // end of listening!
          String fileName = splited[splited.length - 2];
          String filePath = "${directory.path}/$fileName";
          await _createIfDoesntExists(filePath);
          var img = File(filePath);

          await img.writeAsBytes(
              Base64Codec().decode(concatImg)); // img is written here :)

          return splited;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<void> socketWrite(email, nome, resposta) async {
    clientSocket.write('$email§$nome§$resposta');
  }
}
