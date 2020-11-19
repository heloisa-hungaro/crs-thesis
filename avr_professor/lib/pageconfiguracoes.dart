import 'package:flutter/material.dart';
import './xmlfuncoes.dart';
import './xmlloginfuncoes.dart';
import './buildpatterns.dart';
import './pagegerenciarturmas.dart';
import './main.dart' as main;

FileXML file = FileXML();
LoginXML loginFile = LoginXML();

// ---------------------------------------------------------------------------------------------- //

// CONFIGURAÇÕES

class Configuracoes extends StatefulWidget {
  final email;
  Configuracoes({this.email});

  @override
  State<StatefulWidget> createState() => ConfiguracoesState(email: email);
}

class ConfiguracoesState extends State<Configuracoes> {
  String email;
  ConfiguracoesState({this.email});
  bool _editingName = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  FocusNode nameFocusNode;

  @override
  initState() {
    nameFocusNode = FocusNode();
    file.getUserName(email).then((result) {
      setState(() {
        _nameController.text = result;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("CONFIGURAÇÕES"),
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
                Navigator.popAndPushNamed(context, '/questionario');
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
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _nameController,
                      enabled: _editingName ? true : false,
                      focusNode: nameFocusNode,
                      decoration: InputDecoration(
                          labelText: 'Nome Completo:',
                          labelStyle: TextStyle(color: Colors.black)),
                      validator: (String value) {
                        if ((value.isEmpty) ||
                            (value.trim().toUpperCase() == 'ANÔNIMO')) {
                          return 'Digite seu nome completo';
                        }
                      },
                    ),
                  ),
                  _editingName
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                              buildButton('SALVAR', () async {
                                setState(() {
                                  if (_formKey.currentState.validate()) {
                                    _editingName = false;
                                    file
                                        .changeUserName(
                                            _nameController.text.trim(), email)
                                        .then((result) {
                                      main.userName =
                                          _nameController.text.trim();
                                    });
                                  } else {
                                    FocusScope.of(context)
                                        .requestFocus(nameFocusNode);
                                  }
                                });
                              }),
                              buildButton('CANCELAR', () async {
                                setState(() {
                                  _editingName = false;
                                  file.getUserName(email).then((result) {
                                    setState(() {
                                      _nameController.text = result;
                                    });
                                  });
                                });
                              }),
                            ])
                      : buildButton('ALTERAR NOME', () async {
                          setState(() {
                            _editingName = true;
                          });
                          FocusScope.of(context).requestFocus(nameFocusNode);
                        }),
                ]),
              ),
              _editingName
                  ? Container(width: 0, height: 0)
                  : buildButton(
                      'GERENCIAR TURMAS',
                      _editingName
                          ? null
                          : () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        new GerenciarTurmas(email: email)),
                              );
                            }),
              _editingName
                  ? Container(width: 0, height: 0)
                  : buildButton(
                      'SOBRE',
                      _editingName
                          ? null
                          : () async {
                              Navigator.pushNamed(context, '/sobre');
                            }),
              _editingName
                  ? Container(width: 0, height: 0)
                  : buildButton(
                      'SAIR',
                      _editingName
                          ? null
                          : () async {
                              bool success;
                              await _signOutWithGoogle().then((result) {
                                success = result;
                                if (success == true) {
                                  main.userLogged = false;
                                  main.userName = '';
                                  main.userEmail = '';
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/home', (Route<dynamic> route) => false);
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AlertDialog(
                                        title: Text("Erro ao efetuar login"),
                                        content: new Text(
                                            "Verifique sua conexão com a internet."),
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
            ]),
      ),
    );
  }

  Future<bool> _signOutWithGoogle() async {
    try {
      loginFile.writeLoggedOut(email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
