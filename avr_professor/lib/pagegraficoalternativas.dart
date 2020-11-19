import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import './pagelistarespostasturma.dart';

// ---------------------------------------------------------------------------------------------- //

// GRAFICO ALTERNATIVAS

class GraficoAlternativas extends StatefulWidget {
  final turma;
  final questao;
  final listPlot;
  final listAlunos;
  GraficoAlternativas(
      {this.turma, this.questao, this.listPlot, this.listAlunos});

  @override
  State<StatefulWidget> createState() => GraficoAlternativasState(
      turma: turma,
      questao: questao,
      listPlot: listPlot,
      listAlunos: listAlunos);
}

class GraficoAlternativasState extends State<GraficoAlternativas> {
  String turma;
  String questao;
  List<Tuple2> listAlunos;
  List<int> listPlot;
  var colorsBar;
  int max = 30;
  GraficoAlternativasState(
      {this.turma, this.questao, this.listPlot, this.listAlunos});
  List<List<String>> myData = [];

  @override
  initState() {
    colorsBar = [
      charts.Color.fromHex(code: '#FF0000'),
      charts.Color.fromHex(code: '#00CC44')
    ];
    max = listPlot[0];

    int correta = listPlot[listPlot.length - 1];
    for (var i = 0; i < listPlot.length - 1; i++) {
      List<String> aux = [];
      aux.add(String.fromCharCode(65 + i));
      aux.add(listPlot[i].toString());
      if ((i + 1) == correta) {
        aux.add('1');
      } else {
        aux.add('0');
      }

      myData.add(aux);
      if (listPlot[i] > max) {
        max = listPlot[i];
      }
    }
    max = ((max ~/ 10) + 1) * 10;
    // print(myData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("ESTATÍSTICAS"),
      ),
      body: ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Turma: $turma',
                style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Questão: $questao',
                style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Nº de respostas x Alternativas',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new ListaRespostasTurma(
                          turma: turma,
                          questao: questao,
                          listAlunos: listAlunos,
                          correta: listPlot[listPlot.length - 1])),
                );
              },
              child: Container(
                padding: new EdgeInsets.all(15.0),
                height: 400,
                child: new charts.BarChart(
                  [
                    new charts.Series(
                      colorFn: (data, __) => colorsBar[int.parse(data[2])],
                      domainFn: (data, _) => data[0],
                      measureFn: (data, _) => num.parse(data[1]),
                      id: 'Alternativas',
                      data: myData,
                    ),
                  ],
                  animate: false,
                  defaultInteractions: false,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Toque sobre o gráfico para ver as respostas de cada aluno',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
    );
  }
}
