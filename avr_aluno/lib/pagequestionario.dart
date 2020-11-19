import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import './buildpatterns.dart';
import './xmlipfuncoes.dart';
import './pageimagemquestao.dart';
import './cliente.dart';

IpXML ipFile = IpXML();
Cliente client = Cliente();

// ---------------------------------------------------------------------------------------------- //

// QUESTIONARIO

class Questionario extends StatefulWidget {
  final email;
  Questionario({this.email});

  @override
  State<StatefulWidget> createState() => QuestionarioState(email: email);
}

class QuestionarioState extends State<Questionario>
    with SingleTickerProviderStateMixin {
  String email;
  QuestionarioState({this.email});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  AnimationController animationController;
  bool loading = false;
  String animText = '';

  @override
  initState() {
    ipFile.checkIfIpFileExists().then((exists) {
      if (exists == true) {
        ipFile.getIpData().then((_) {
          setState(() {
            _ipController.text = ipFile.conexao.ip;
            _portController.text = ipFile.conexao.porta;
          });
        });
      } else {
        _portController.text = '4041';
      }
    });
    super.initState();

    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("RESPONDER QUESTÃO"),
      ),
      drawer: (email == 'anonimo')
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  SizedBox(
                    height: 80,
                    child: DrawerHeader(
                      child: Text('MENU - Avr Aluno',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      decoration: BoxDecoration(
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Responder Questão'),
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ListTile(
                    title: Text('Estatísticas'),
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/estatisticas');
                    },
                  ),
                  ListTile(
                    title: Text('Configurações'),
                    onTap: () {
                      Navigator.popAndPushNamed(context, '/configuracoes');
                    },
                  ),
                ],
              ),
            ),
      body: loading
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '$animText',
                        style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AnimatedBuilder(
                      animation: animationController,
                      child: new Container(
                        height: 150.0,
                        width: 150.0,
                        child: Icon(Icons.rotate_right),
                      ),
                      builder: (BuildContext context, Widget _widget) {
                        return new Transform.rotate(
                          angle: animationController.value * 6.3,
                          child: _widget,
                        );
                      },
                    ),
                  ]),
            )
          : // not loading!
          Column(children: <Widget>[
              Expanded(
                flex: 1,
                child: Center(
                  child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              'Dados para conexão:',
                              style: TextStyle(
                                  fontSize: 20, color: Colors.blue[900]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 200.0,
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
                            child: TextFormField(
                              controller: _ipController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  labelText: 'IP:',
                                  labelStyle: TextStyle(color: Colors.black)),
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Digite o IP';
                                }
                                Pattern pattern =
                                    r'^[0-9]{1,3}[\.][0-9]{1,3}[\.][0-9]{1,3}[\.][0-9]{1,3}$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(value))
                                  return 'Digite um IP válido!';
                                else
                                  return null;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                                BlacklistingTextInputFormatter
                                    .singleLineFormatter,
                                WhitelistingTextInputFormatter(RegExp("[0-9.]"))
                              ],
                            ),
                          ),
                          Container(
                            width: 200.0,
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
                            child: TextFormField(
                              controller: _portController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                  labelText: 'Porta:',
                                  labelStyle: TextStyle(color: Colors.black)),
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Digite a Porta';
                                }
                                Pattern pattern = r'^[0-9]{1,5}$';
                                RegExp regex = new RegExp(pattern);
                                if (!regex.hasMatch(value))
                                  return 'Digite uma porta válida!';
                                else
                                  return null;
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(5),
                                BlacklistingTextInputFormatter
                                    .singleLineFormatter,
                                WhitelistingTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          buildButton('RESPONDER QUESTÃO', () async {
                            if (_formKey.currentState.validate()) {
                              client.ip = _ipController.text;
                              client.porta = _portController.text;
                              setState(() {
                                loading = true;
                                animationController.repeat();
                                animText =
                                    'Tentanto conectar com o servidor...';
                              });

                              client.startSocket().then((serverWorks) async {
                                if (serverWorks) {
                                  ipFile.saveIpData(client.ip, client.porta);

                                  setState(() {
                                    animText = 'Recebendo dados do servidor...';
                                  });

                                  client
                                      .socketListen()
                                      .then((dadosQuestao) async {
                                    if (dadosQuestao == null) {
                                      // erro no listen
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                "Erro ao receber dados do servidor"),
                                            content: new Text(
                                                "Problema durante a conexão. Verifique se o servidor foi encerrado."),
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
                                      setState(() {
                                        loading = false;
                                        animationController.stop(
                                            canceled: true);
                                      });
                                    } else {
                                      Directory directory =
                                          await getApplicationDocumentsDirectory();
                                      String fileName =
                                          dadosQuestao[dadosQuestao.length - 2];
                                      File fileQuestao =
                                          File("${directory.path}/$fileName");
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                new ImagemQuestao(
                                                    email: email,
                                                    dadosQuestao: dadosQuestao,
                                                    fileQuestao: fileQuestao,
                                                    client: client)),
                                      );
                                      await fileQuestao.delete();
                                      setState(() {
                                        animationController.stop(
                                            canceled: true);
                                        loading = false;
                                      });
                                    }
                                  });
                                } else {
                                  setState(() {
                                    animationController.stop(canceled: true);
                                    loading = false;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(
                                            "Erro ao conectar no servidor"),
                                        content: new Text(
                                            "Verifique ip e porta informados."),
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
                                  setState(() {
                                    animationController.stop(canceled: true);
                                    loading = false;
                                  });
                                }
                              });
                            }
                          }),
                        ]),
                  ),
                ),
              ),
            ]),
    );
  }
}
