import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import './xmlfuncoes.dart';
import './pagegraficoturma.dart';

FileXML file = FileXML();

// ---------------------------------------------------------------------------------------------- //

// ESTATISTICAS

class Estatisticas extends StatefulWidget {
  final email;
  Estatisticas({this.email});

  @override
  State<StatefulWidget> createState() => EstatisticasState(email: email);
}

class EstatisticasState extends State<Estatisticas> {
  String email;
  EstatisticasState({this.email});
  List<String> _turmas = [];
  String textPage = '';
  List<Tuple2> _listPlot = [];
  List<Tuple2> contAcertos = [];

  @override
  initState() {
    file.getTurmas(email).then((result) {
      setState(() {
        _turmas = result;
        if (_turmas.length == 0) {
          textPage = 'Não há turmas ativas';
        } else {
          textPage = 'Selecionar turma';
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
        title: Text("ESTATÍSTICAS"),
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
                Navigator.of(context).pop();
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
                  onTap: () {
                    file.getListPlotTurma(item, email).then((result) {
                      _listPlot = result;
                      contAcertos = file.contAcertos;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new GraficoTurma(
                                email: email,
                                turma: item,
                                listPlot: _listPlot,
                                contAcertos: contAcertos)),
                      );
                    });
                  },
                );
              }),
        ),
      ]),
    );
  }
}
