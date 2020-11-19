import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'dart:io';
import './buildpatterns.dart';
import './xmlipfuncoes.dart';
import './xmlfuncoes.dart';
import './pagegraficoalternativas.dart';
import './pageconexaodados.dart';
import './servidor.dart';

IpXML ipFile = IpXML();
FileXML file = FileXML();

// ---------------------------------------------------------------------------------------------- //

// SOBRE

class EnviarDados extends StatefulWidget {
  final email;
  final turma;
  final data;
  final hora;
  final fileQuestao;
  final correta;
  final posAlt;
  final imgWidth;
  final imgHeight;
  final server;
  final mostraResp;

  EnviarDados(
      {this.email,
      this.turma,
      this.data,
      this.hora,
      this.fileQuestao,
      this.imgWidth,
      this.imgHeight,
      this.correta,
      this.mostraResp,
      this.posAlt,
      this.server});

  @override
  State<StatefulWidget> createState() => EnviarDadosState(
      email: email,
      turma: turma,
      data: data,
      hora: hora,
      fileQuestao: fileQuestao,
      imgWidth: imgWidth,
      imgHeight: imgHeight,
      correta: correta,
      mostraResp: mostraResp,
      posAlt: posAlt,
      server: server);
}

class EnviarDadosState extends State<EnviarDados> {
  String email;
  String turma;
  String data;
  String hora;
  File fileQuestao;
  double imgWidth;
  double imgHeight;
  int correta;
  bool mostraResp;
  List<Tuple2> posAlt;
  Servidor server;

  List<int> listAlternativas; // for chart
  List<Tuple2> listAlunos; // for chart
  int numRespostas = 0;
  int numRespAnon = 0;

  EnviarDadosState(
      {this.email,
      this.turma,
      this.data,
      this.hora,
      this.fileQuestao,
      this.imgWidth,
      this.imgHeight,
      this.correta,
      this.mostraResp,
      this.posAlt,
      this.server});

  @override
  initState() {
    super.initState();
    server.parent = this;
    setState(() {
      server.startServer().then((serverWorks) {
        if (serverWorks) {
          ipFile.saveIpData(server.ip, server.porta);
          file.getUserName(email).then((userName) {
            server
                .startListening(userName, turma, data, hora, imgWidth,
                    imgHeight, correta, mostraResp, posAlt, fileQuestao)
                .then((_) {
              setState(() {});
            });
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new ConexaoDados(server: server)),
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Erro ao iniciar servidor"),
                content: new Text("Verifique ip e porta informados."),
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
      });
    });
  }

  void update() {
    setState(() {
      numRespostas = server.numRespostas;
      numRespAnon = server.numRespAnon;
    });
  }

  void erroSocket() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erro no servidor"),
          content: new Text(
              "Ocorreu um erro com o servidor, verifique por mudanças na rede.\nA questão será finalizada."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                finalizaQuestao();
              },
            ),
          ],
        );
      },
    );
  }

  void finalizaQuestao() {
    server.closeServer();
    if (numRespostas == 0) {
      Navigator.of(context).pop();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
    } else {
      String questao = "$data às $hora";

      file
          .saveNewQuestion(email, turma, data, hora, posAlt.length, correta,
              server.receivedAnswers)
          .then((_) {
        file.getListPlotQuestaoTurma(turma, questao, email).then((result) {
          listAlternativas = result;
          file.getListAlunosQuestao().then((result) {
            listAlunos = result;
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home', (Route<dynamic> route) => false);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => new GraficoAlternativas(
                      turma: turma,
                      questao: questao,
                      listPlot: listAlternativas,
                      listAlunos: listAlunos)),
            );
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("SERVIDOR"),
        leading: Container(),
      ),
      body: Column(children: <Widget>[
        Expanded(
          flex: 1,
          child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                    child: Text(
                      'IP:\n${server.ip}',
                      style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 40.0),
                    child: Text(
                      'Porta:\n${server.porta}',
                      style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 40.0),
                    child: Text(
                      '''Respostas recebidas: $numRespostas\n[$numRespAnon anônima(s)]''',
                      style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Toque no botão abaixo para finalizar o envio de dados aos alunos e ver o gráfico desta questão',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  buildButton('FINALIZAR', () async {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Finalizar questão"),
                          content: new Text(
                              "Deseja realmente parar a troca de dados com os alunos?"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("Confirmar"),
                              onPressed: () {
                                finalizaQuestao();
                              },
                            ),
                            new FlatButton(
                              child: new Text("Cancelar"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ]),
          ),
        ),
      ]),
    );
  }
}
