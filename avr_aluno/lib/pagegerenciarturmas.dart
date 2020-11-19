import 'package:flutter/material.dart';
import './xmlfuncoes.dart';

FileXML file = FileXML();

// ---------------------------------------------------------------------------------------------- //

// GERENCIAR TURMAS

class GerenciarTurmas extends StatefulWidget {
  final email;
  GerenciarTurmas({this.email});

  @override
  State<StatefulWidget> createState() => GerenciarTurmasState(email: email);
}

class GerenciarTurmasState extends State<GerenciarTurmas> {
  String email;
  GerenciarTurmasState({this.email});
  List<String> _turmas = [];
  String textPage = '';

  @override
  initState() {
    file.getTurmas(email).then((result) {
      setState(() {
        _turmas = result;
        if (_turmas.length == 0) {
          textPage = 'Não há turmas ativas';
        } else {
          textPage = 'Remover dados de turmas';
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("TURMAS"),
      ),
      body: Column(children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '$textPage',
              style: TextStyle(fontSize: 20, color: Colors.blue[900]),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
              padding: const EdgeInsets.all(5.0),
              itemCount: _turmas.length * 2,
              itemBuilder: (context, int i) {
                if (i.isOdd) {
                  return Divider();
                }
                final int index = i ~/ 2;
                String item = _turmas[index];
                return ListTile(
                  title: Text(item),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // return object of type Dialog
                          return AlertDialog(
                            title: Text("Remover turma"),
                            content: new Text(
                                "Deseja realmente deletar todos os dados da turma $item?"),
                            actions: <Widget>[
                              // usually buttons at the bottom of the dialog
                              new FlatButton(
                                child: new Text("Confirmar"),
                                onPressed: () {
                                  file.removeTurma(item, email).then((x) {
                                    file.getTurmas(email).then((result) {
                                      setState(() {
                                        _turmas = result;
                                        if (_turmas.length == 0) {
                                          textPage = 'Não há turmas ativas';
                                        } else {
                                          textPage = 'Remover dados de turmas';
                                        }
                                      });
                                    });
                                  });

                                  Navigator.of(context).pop();
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
                    },
                  ),
                );
              }),
        ),
      ]),
    );
  }
}
