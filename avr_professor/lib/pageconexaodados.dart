import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:get_ip/get_ip.dart';
import 'dart:async';
import './buildpatterns.dart';
import './xmlipfuncoes.dart';
import './servidor.dart';

IpXML ipFile = IpXML();

// ---------------------------------------------------------------------------------------------- //

// CONEXAO

class ConexaoDados extends StatefulWidget {
  final server;

  ConexaoDados({this.server});

  @override
  State<StatefulWidget> createState() => ConexaoDadosState(server: server);
}

class ConexaoDadosState extends State<ConexaoDados> {
  Servidor server;

  ConexaoDadosState({this.server});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _portController = TextEditingController();

  StreamSubscription<ConnectivityResult> _subscription;
  String meuIp = '';
  String statusConexao = '';

  void setIp(result) async {
    meuIp = '';
    meuIp = await GetIp.ipAddress;
    if (result == ConnectivityResult.mobile) {
      statusConexao = 'Conectado à rede móvel.\n Desative os dados móveis!';
      meuIp = '-';
    } else if (result == ConnectivityResult.wifi) {
      Connectivity().getWifiIP().then((ip) {
        meuIp = ip;
      });
      statusConexao = "Conectado à rede WiFi";
    } else {
      if (meuIp != null && meuIp != '') {
        statusConexao = "Conectado como Hotspot";
      } else {
        meuIp = '?';
        statusConexao =
            "Sem conexão.\nConecte-se a uma rede WiFi ou inicie um Hotspot!";
      }
    }
    setState(() {});
  }

  @override
  initState() {
    Connectivity().checkConnectivity().then((result) {
      setIp(result);
    });
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setIp(result);
    });

    ipFile.checkIfIpFileExists().then((exists) {
      if (exists == true) {
        ipFile.getIpData().then((_) {
          setState(() {
            _portController.text = ipFile.porta;
          });
        });
      } else {
        _portController.text = '4041';
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("DADOS SERVIDOR"),
        leading: Container(),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                    child: Text(
                      'Não foi possível iniciar o servidor...\nTente novamente:',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Dados para conexão:',
                      style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Status: $statusConexao',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'IP:   $meuIp',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.zero,
                    child: buildButton(
                        'INICIEI UM HOTSPOT',
                        (meuIp != '?')
                            ? null
                            : () async {
                                Connectivity()
                                    .checkConnectivity()
                                    .then((result) {
                                  setIp(result);
                                });
                                if (meuIp == '?') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AlertDialog(
                                        title: Text("Iniciou realmente?"),
                                        content: new Text(
                                            "Não foi possível identificar o Hotspot."),
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
                              }),
                  ),
                  Container(
                    width: 200.0,
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 50.0),
                    child: TextFormField(
                      controller: _portController,
                      keyboardType: TextInputType.number,
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
                        BlacklistingTextInputFormatter.singleLineFormatter,
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  buildButton(
                      'CONECTAR',
                      (meuIp == '?' || meuIp == '-')
                          ? null
                          : () async {
                              server.ip = meuIp;
                              server.porta = _portController.text;

                              server.startServer().then((serverWorks) {
                                if (serverWorks) {
                                  Navigator.of(context).pop();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Erro ao iniciar servidor"),
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
                                }
                              });
                            }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                    child: buildButton('CANCELAR QUESTÃO', () async {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home', (Route<dynamic> route) => false);
                    }),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
