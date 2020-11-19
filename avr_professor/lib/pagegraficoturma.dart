import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:fcharts/fcharts.dart';
import './buildpatterns.dart';
import './pageestatisticasalunos.dart';
import './pagelistaquestoesturma.dart';

// ---------------------------------------------------------------------------------------------- //

// GRAFICO TURMA

class GraficoTurma extends StatefulWidget {
  final email;
  final turma;
  final contAcertos;
  final listPlot;
  GraficoTurma({this.email, this.turma, this.listPlot, this.contAcertos});

  @override
  State<StatefulWidget> createState() => GraficoTurmaState(
      email: email, turma: turma, listPlot: listPlot, contAcertos: contAcertos);
}

class GraficoTurmaState extends State<GraficoTurma> {
  String turma;
  String email;
  List<Tuple2> listPlot;
  List<Tuple2> contAcertos;
  GraficoTurmaState({this.email, this.turma, this.listPlot, this.contAcertos});
  List<List<String>> myData = [];

  @override
  initState() {
    var count = 1;
    listPlot.forEach((k) {
      List<String> aux = [];
      aux.add(count.toString());
      aux.add(k.item2.toString());
      myData.add(aux);
      count++;
    });

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
              alignment: Alignment.center,
              child: buildButton('VER ALUNOS', () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          new EstatisticasAlunos(email: email, turma: turma)),
                );
              }),
            ),
            Container(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Desempenho x Nº de questões',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => new ListaQuestoesTurma(
                          turma: turma,
                          listPlot: listPlot,
                          email: email,
                          contAcertos: contAcertos)),
                );
              },
              child: Container(
                height: 400,
                child: LineChart(
                  lines: [
                    new Line<List<String>, String, double>(
                      data: myData,
                      xFn: (datum) => datum[0],
                      yFn: (datum) => num.parse(datum[1]),
                      yAxis: new ChartAxis(
                        span: new DoubleSpan(0, 100),
                        tickGenerator: IntervalTickGenerator.byN(10),
                      ),
                      stroke: PaintOptions.stroke(color: Colors.blue[800]),
                      marker: MarkerOptions(
                        paint: PaintOptions.fill(color: Colors.blue[900]),
                        shape: MarkerShapes.circle,
                      ),
                    ),
                  ],
                  chartPadding: new EdgeInsets.fromLTRB(40.0, 30.0, 20.0, 30.0),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Toque sobre o gráfico para ver o histórico de desempenho',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ]),
    );
  }
}
