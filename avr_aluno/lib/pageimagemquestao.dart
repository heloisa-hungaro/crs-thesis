import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:get_ip/get_ip.dart';
import 'dart:io';
import './xmlfuncoes.dart';
import './cliente.dart';

FileXML file = FileXML();

GlobalKey key = GlobalKey();

// ---------------------------------------------------------------------------------------------- //

// IMAGEM QUESTAO

class ImagemQuestao extends StatefulWidget {
  final email;
  final dadosQuestao;
  final client;
  final fileQuestao;
  ImagemQuestao({this.email, this.dadosQuestao, this.fileQuestao, this.client});

  @override
  State<StatefulWidget> createState() => ImagemQuestaoState(
      email: email,
      dadosQuestao: dadosQuestao,
      fileQuestao: fileQuestao,
      client: client);
}

class ImagemQuestaoState extends State<ImagemQuestao> {
  String email;
  List dadosQuestao;
  Cliente client;
  File fileQuestao;
  ImagemQuestaoState(
      {this.email, this.dadosQuestao, this.fileQuestao, this.client});

  bool closedSocket = false;

  // set teste info! falta implementar servidor para pegar esses dados
  String turma;
  String professor;
  String data;
  String hora;
  String fileName;
  double imgWidth;
  double imgHeight;
  List<Tuple2> posAlt = [];
  int correta;
  int mostraResp;

  double boxSize = 50;
  int escolha = 0;
  bool respondeu = false;
  int numAlt = 0;
  int acertou;
  double newImgWidth;
  double newImgHeight;
  double propBoxWidth = 50;
  double propBoxHeight = 50;
  double propH = 1;
  double propW = 1;

  String textBefAnswer = 'Selecione uma alternativa na imagem';

  _afterLayout(_) {
    RenderBox box = key.currentContext.findRenderObject();
    newImgWidth = box.size.width;
    newImgHeight = box.size.height;

    propW = (newImgWidth / imgWidth);
    propH = (newImgHeight / imgHeight);
    propBoxWidth = propW * boxSize;
    propBoxHeight = propH * boxSize;
    if (propBoxWidth < 20) {
      propBoxWidth = 20;
    }
    if (propBoxHeight < 20) {
      propBoxHeight = 20;
    }
    setState(() {});
  }

  Future<void> splitDadosQuestao() async {
    professor = dadosQuestao[0];
    turma = dadosQuestao[1];
    data = dadosQuestao[2];
    hora = dadosQuestao[3];
    imgWidth = num.parse(dadosQuestao[4]);
    imgHeight = num.parse(dadosQuestao[5]);
    numAlt = int.parse(dadosQuestao[6]);
    correta = int.parse(dadosQuestao[7]);
    mostraResp = int.parse(dadosQuestao[8]);
    posAlt.clear();
    for (var i = 0; i < numAlt; i++) {
      double auxW = num.parse(dadosQuestao[9 + (2 * i)]);
      double auxH = num.parse(dadosQuestao[10 + (2 * i)]);
      posAlt.add(Tuple2<double, double>(auxW, auxH));
    }
  }

  @override
  void didChangeDependencies() async {
    splitDadosQuestao().then((_) async {
      await precacheImage(AssetImage(fileQuestao.path), context);
      WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
      super.didChangeDependencies();
    });
  }

  @override
  void dispose() {
    if (!closedSocket) {
      client.closeSocket();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("RESPONDER QUESTÃO"),
        actions: <Widget>[
          respondeu
              ? Container()
              : IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    if (escolha == 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Resposta?"),
                            content: new Text("Selecione alguma alternativa!"),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      setState(() {
                        respondeu = true;
                        textBefAnswer = '';
                      });

                      String textDialog;
                      String titleDialog;
                      if (escolha == correta) {
                        acertou = 1;
                      } else {
                        acertou = 0;
                      }
                      if (mostraResp == 0) {
                        titleDialog = "Será que você acertou?";
                        textDialog =
                            "Verifique com o professor a resposta correta.";

                      } else {
                        if (escolha == correta) {
                          titleDialog = "Muito bem!";
                          textDialog = "Resposta correta.";
                        } else {
                          titleDialog = "Que pena!";
                          textDialog = "Você errou desta vez.";
                        }
                      }
                      if (email == 'anonimo') {
                        try {
                          GetIp.ipAddress.then((thisIp) {
                            client.socketWrite(thisIp, 'Anônimo', escolha);
                            client.closeSocket();
                            closedSocket = true;
                          });
                        } catch (e) {
                          print(e);
                        }
                      } else {
                        file.getUserName(email).then((userName) {
                          try {
                            client.socketWrite(email, userName, escolha);
                            client.closeSocket();
                            closedSocket = true;
                          } catch (e) {
                            print(e);
                          }
                        });
                        String obsAcertou =
                            ''; // salva com * se não exibe resposta, p/ uso em estatisticas
                        obsAcertou = acertou.toString();
                        if (mostraResp == 0) {
                          obsAcertou = '$obsAcertou*';
                        }
                        file
                            .saveNewQuestion(
                            email, turma, professor, data, hora, obsAcertou)
                            .then((_) {});
                      }
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(titleDialog),
                            content: new Text(textDialog),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
        ],
      ),
      body: Column(children: <Widget>[
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            '$textBefAnswer',
            style: TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5.0)),
              child: Stack(children: <Widget>[
                Image.asset(
                  fileQuestao.path,
                  fit: BoxFit.scaleDown,
                  key: key,
                ),
                _drawBox(1, posAlt[0].item1 * propH, posAlt[0].item2 * propW,
                    propBoxWidth, propBoxHeight),
                _drawBox(2, posAlt[1].item1 * propH, posAlt[1].item2 * propW,
                    propBoxWidth, propBoxHeight),
                numAlt > 2
                    ? _drawBox(3, posAlt[2].item1 * propH,
                        posAlt[2].item2 * propW, propBoxWidth, propBoxHeight)
                    : _drawBox(3, 0, 0, 0, 0),
                numAlt > 3
                    ? _drawBox(4, posAlt[3].item1 * propH,
                        posAlt[3].item2 * propW, propBoxWidth, propBoxHeight)
                    : _drawBox(4, 0, 0, 0, 0),
                numAlt > 4
                    ? _drawBox(5, posAlt[4].item1 * propH,
                        posAlt[4].item2 * propW, propBoxWidth, propBoxHeight)
                    : _drawBox(5, 0, 0, 0, 0),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Positioned _drawBox(
      int boxNum, double boxLeft, double boxTop, double boxW, double boxH) {
    // boxNum = 1, alt = A
    return Positioned(
      left: boxLeft,
      top: boxTop,
      width: boxW,
      height: boxH,
      child: GestureDetector(
        child: Container(
          color: respondeu
              ? (mostraResp == 0
                  ? (escolha == boxNum
                      ? Colors.deepPurple[
                          900] // respondeu, não mostra correta, é resposta do aluno
                      : Colors.blueAccent.withOpacity(
                          0.3)) // respondeu, não mostra correta, não é resposta do aluno
                  : (correta == boxNum
                      ? Colors
                          .green // respondeu, mostra correta, é resposta correta
                      : (escolha == boxNum
                          ? Colors
                              .red // respondeu, mostra correta, é resposta do aluno e não é a correta
                          : Colors.blueAccent.withOpacity(
                              0.3)))) // respondeu, mostra correta, não é a correta nem é resposta do aluno
              : (escolha == boxNum
                  ? Colors.indigo[900]
                  : Colors
                      .blueAccent), // aluno ainda não respodeu ; indigo é a selecionada
          child: Center(
            child: Text(
              String.fromCharCode(64 + boxNum),
              style: TextStyle(
                  fontSize: 30 * propH,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        onTap: () {
          if (respondeu == false) {
            setState(() {
              escolha = boxNum;
            });
          }
        },
      ),
    );
  }
}
