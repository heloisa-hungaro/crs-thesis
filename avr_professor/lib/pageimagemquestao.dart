import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:date_format/date_format.dart';
import 'dart:io';
import './pageenviardados.dart';
import './servidor.dart';

GlobalKey key = GlobalKey();
int _correta = 0;
// ---------------------------------------------------------------------------------------------- //

// IMAGEM QUESTAO

class ImagemQuestao extends StatefulWidget {
  final email;
  final turma;
  final fileQuestao;
  final server;
  final mostraResp;
  ImagemQuestao(
      {this.email, this.turma, this.mostraResp, this.fileQuestao, this.server});

  @override
  State<StatefulWidget> createState() => ImagemQuestaoState(
      email: email,
      turma: turma,
      mostraResp: mostraResp,
      fileQuestao: fileQuestao,
      server: server);
}

class ImagemQuestaoState extends State<ImagemQuestao> {
  String email;
  String turma;
  File fileQuestao;
  Servidor server;
  bool mostraResp;
  ImagemQuestaoState(
      {this.email, this.turma, this.mostraResp, this.fileQuestao, this.server});

  double imgWidth;
  double imgHeight;
  double boxSize = 50;
  int cont = 0;
  List<Tuple2> pos = [];

  @override
  initState() {
    _correta = 0;
    super.initState();
  }

  _getSizeAfterLayout(_) {
    RenderBox box = key.currentContext.findRenderObject();
    imgWidth = box.size.width;
    imgHeight = box.size.height;
  }

  @override
  void didChangeDependencies() async {
    await precacheImage(AssetImage(fileQuestao.path), context);
    WidgetsBinding.instance.addPostFrameCallback(_getSizeAfterLayout);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("ALTERNATIVAS"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              String textDialog;
              if (cont < 2) {
                textDialog = 'Selecione ao menos duas alternativas!';
              } else {
                if (_correta == 0) {
                  textDialog = 'Selecione a alternativa correta!';
                } else {
                  // tudo certo!!!
                  DateTime agora = new DateTime.now();
                  String data = formatDate(agora, [dd, '\/', mm, '\/', yy]);
                  String hora = formatDate(agora, [HH, ':', nn]);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => new EnviarDados(
                            email: email,
                            turma: turma,
                            data: data,
                            hora: hora,
                            fileQuestao: fileQuestao,
                            imgWidth: imgWidth,
                            imgHeight: imgHeight,
                            correta: _correta,
                            mostraResp: mostraResp,
                            posAlt: pos,
                            server: server)),
                  );
                  return;
                }
              }
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Está faltando algo..."),
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
            },
          ),
        ],
      ),
      body: Column(children: <Widget>[
        Container(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'Selecione as alternativas na imagem e toque novamente para selecionar a correta\nDê dois toques para apagar uma alternativa',
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
                GestureDetector(
                  child: Image.asset(
                    fileQuestao.path,
                    fit: BoxFit.scaleDown,
                    key: key,
                  ),
                  onTapUp: (TapUpDetails details) {
                    if (cont < 4) {
                      RenderBox box = key.currentContext.findRenderObject();
                      Offset position = box.localToGlobal(Offset.zero);
                      double x = details.globalPosition.dx -
                          position.dx; // user clicked here!
                      double y = details.globalPosition.dy -
                          position.dy; // user clicked here!

                      //imgWidth = box.size.width;
                      //imgHeight = box.size.height;

                      // container will be draw on x-size/2 and y-size/2 to center based on tap
                      x = x - (boxSize / 2);
                      y = y - (boxSize / 2);

                      setState(() {
                        pos.add(Tuple2<double, double>(x, y));
                        cont++;
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Ops..."),
                            content: new Text("O máximo de alternativas é 4!"),
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
                cont > 0
                    ? _drawBox(1, pos[0].item1, pos[0].item2, boxSize)
                    : _drawBox(1, 0.0, 0.0, 0),
                cont > 1
                    ? _drawBox(2, pos[1].item1, pos[1].item2, boxSize)
                    : _drawBox(2, 0.0, 0.0, 0),
                cont > 2
                    ? _drawBox(3, pos[2].item1, pos[2].item2, boxSize)
                    : _drawBox(3, 0.0, 0.0, 0),
                cont > 3
                    ? _drawBox(4, pos[3].item1, pos[3].item2, boxSize)
                    : _drawBox(4, 0.0, 0.0, 0),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Positioned _drawBox(int boxNum, double boxLeft, double boxTop, double boxWH) {
    // boxNum = 1, alt = A
    return Positioned(
      left: boxLeft,
      top: boxTop,
      width: boxWH,
      height: boxWH,
      child: GestureDetector(
        child: Container(
          color: _correta == 0
              ? Colors.blueAccent
              : (_correta == boxNum ? Colors.green : Colors.red),
          child: Center(
            child: Text(
              String.fromCharCode(64 + boxNum),
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        onTap: () {
          setState(() {
            _correta = boxNum;
          });
        },
        onDoubleTap: () {
          setState(() {
            pos.removeAt(boxNum - 1);
            cont--;
            if (_correta == boxNum) {
              _correta = 0;
            } else {
              if (_correta > boxNum) {
                _correta--;
              }
            }
          });
        },
      ),
    );
  }
}
