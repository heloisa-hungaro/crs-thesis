import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:get_ip/get_ip.dart';
import 'dart:io';
import 'dart:async';
import './buildpatterns.dart';
import './xmlipfuncoes.dart';
import './xmlfuncoes.dart';
import './pageimagemquestao.dart';
import './main.dart';
import './servidor.dart';

IpXML ipFile = IpXML();
FileXML file = FileXML();

// ---------------------------------------------------------------------------------------------- //

// QUESTIONARIO

class Questionario extends StatefulWidget {
  final email;
  Questionario({this.email});

  @override
  State<StatefulWidget> createState() => QuestionarioState(email: email);
}

class QuestionarioState extends State<Questionario> {
  String email;
  String _turma;
  QuestionarioState({this.email});
  File fileNovaQuestao;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTurmaController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  FocusNode nameTurmaFocusNode;

  StreamSubscription<ConnectivityResult> _subscription;
  String meuIp;
  String statusConexao;
  ConnectivityResult last;

  List<String> listTurmas = [];
  String dropdownValue;

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
      setState(() {
        if (exists == true) {
          ipFile.getIpData().then((_) {
            _portController.text = ipFile.porta;
          });
        } else {
          _portController.text = '4041';
        }
      });
    });
    nameTurmaFocusNode = FocusNode();
    _nameTurmaController.text = '';
    file.getTurmas(email).then((result) {
      setState(() {
        listTurmas = result;
        listTurmas.sort((a, b) => (a.toUpperCase()).compareTo(b.toUpperCase()));
        listTurmas.add('NOVA TURMA');
        if (!listTurmas.contains(turmaSelec)) {
          turmaSelec = 'NOVA TURMA';
        }
        dropdownValue = turmaSelec;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    nameTurmaFocusNode.dispose();
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("NOVA QUESTÃO"),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 80,
              child: DrawerHeader(
                child: Text('MENU - Avr Professor',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                ),
              ),
            ),
            ListTile(
              title: Text('Nova Questão'),
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
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
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
                            Connectivity().checkConnectivity().then((result) {
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
              Container(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Selecione a turma:',
                  style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5.0, 0.0, 5.0, 0.0),
                child: DropdownButton(
                  value: dropdownValue,
                  onChanged: (String newValue) {
                    setState(() {
                      turmaSelec = newValue;
                      dropdownValue = newValue;
                      if (dropdownValue == 'NOVA TURMA') {
                        FocusScope.of(context).requestFocus(nameTurmaFocusNode);
                      }
                    });
                  },
                  items:
                      listTurmas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              dropdownValue == 'NOVA TURMA'
                  ? Container(
                      width: 250.0,
                      height: 60.0,
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: TextFormField(
                        controller: _nameTurmaController,
                        focusNode: nameTurmaFocusNode,
                        decoration: InputDecoration(
                            labelText: 'Nome da nova turma:',
                            labelStyle: TextStyle(color: Colors.black)),
                        validator: (String value) {
                          if ((value.trim().isEmpty) ||
                              (listTurmas
                                  .contains(value.toUpperCase().trim()))) {
                            return 'Digite um nome único para a nova turma';
                          }
                          return null;
                        },
                      ),
                    )
                  : Container(
                      width: 250.0,
                      height: 60.0,
                    ),
              Container(
                width: 400,
                padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                child: CheckboxListTile(
                  value: enviaCorreta,
                  onChanged: (bool value) {
                    setState(() {
                      enviaCorreta = value;
                    });
                  },
                  title: new Text('Enviar resposta correta'),
                  controlAffinity: ListTileControlAffinity.leading,
                  subtitle: new Text('Exibida ao aluno após reponder'),
                  activeColor: Colors.blue[600],
                ),
              ),
              Padding(
                padding: EdgeInsets.zero,
                child: buildButton(
                    'CRIAR QUESTÃO',
                    (meuIp == '?' || meuIp == '-')
                        ? null
                        : () async {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                if (dropdownValue == 'NOVA TURMA') {
                                  _turma = _nameTurmaController.text;
                                  turmaSelec = _turma;
                                } else {
                                  _turma = dropdownValue;
                                }

                                Servidor server = Servidor();
                                server.ip = meuIp;
                                server.porta = _portController.text;

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: new SingleChildScrollView(
                                          child: new ListBody(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    5.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  'Imagem da questão:',
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                              Divider(),
                                              GestureDetector(
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Icon(Icons.add_a_photo),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5.0,
                                                                0.0,
                                                                0.0,
                                                                0.0),
                                                        child: Text(
                                                          'Câmera',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    ]),
                                                onTap: () {
                                                  openCamera().then((result) {
                                                    fileNovaQuestao = result;
                                                    print(fileNovaQuestao);
                                                    if (fileNovaQuestao !=
                                                        null) {
                                                      _cropImage(
                                                              fileNovaQuestao)
                                                          .then((result) {
                                                        fileNovaQuestao =
                                                            result;
                                                        if (fileNovaQuestao !=
                                                            null) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => new ImagemQuestao(
                                                                    email:
                                                                        email,
                                                                    turma:
                                                                        _turma,
                                                                    mostraResp:
                                                                        enviaCorreta,
                                                                    fileQuestao:
                                                                        fileNovaQuestao,
                                                                    server:
                                                                        server)),
                                                          );
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                              ),
                                              Divider(),
                                              GestureDetector(
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Icon(Icons
                                                          .add_photo_alternate),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                5.0,
                                                                0.0,
                                                                0.0,
                                                                0.0),
                                                        child: Text(
                                                          'Galeria',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                    ]),
                                                onTap: () {
                                                  openGallery().then((result) {
                                                    fileNovaQuestao = result;
                                                    print(fileNovaQuestao);
                                                    if (fileNovaQuestao !=
                                                        null) {
                                                      _cropImage(
                                                              fileNovaQuestao)
                                                          .then((result) {
                                                        fileNovaQuestao =
                                                            result;
                                                        if (fileNovaQuestao !=
                                                            null) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => new ImagemQuestao(
                                                                    email:
                                                                        email,
                                                                    turma:
                                                                        _turma,
                                                                    mostraResp:
                                                                        enviaCorreta,
                                                                    fileQuestao:
                                                                        fileNovaQuestao,
                                                                    server:
                                                                        server)),
                                                          );
                                                        }
                                                      });
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              }
                            });
                          }),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<File> openCamera() async {
    return await ImagePicker.pickImage(
      source: ImageSource.camera,
    );
  }

  Future<File> openGallery() async {
    return await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
  }

  Future<File> _cropImage(File imageFile) async {
    return await ImageCropper.cropImage(
        maxHeight: 800,
        maxWidth: 800,
        sourcePath: imageFile.path,
        toolbarTitle: 'Cortar imagem',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white);
  }
}
