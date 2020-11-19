import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:fcharts/fcharts.dart';
import './pagelistaquestoesaluno.dart';

// ---------------------------------------------------------------------------------------------- //

// GRAFICO ALUNO

class GraficoAluno extends StatefulWidget {
  final email;
  final turma;
  final aluno;
  final listPlot;
  final listAlunos;
  GraficoAluno(
      {this.email, this.aluno, this.turma, this.listPlot, this.listAlunos});

  @override
  State<StatefulWidget> createState() => GraficoAlunoState(
      email: email,
      aluno: aluno,
      turma: turma,
      listPlot: listPlot,
      listAlunos: listAlunos);
}

class GraficoAlunoState extends State<GraficoAluno> {
  String turma;
  String email;
  String aluno;
  List<Tuple2> listPlot;
  List<Tuple2> listAlunos;
  GraficoAlunoState(
      {this.email, this.aluno, this.turma, this.listPlot, this.listAlunos});
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
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'Aluno: $aluno',
                style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                'E-mail: $email',
                style: TextStyle(fontSize: 20, color: Colors.blue[900]),
                textAlign: TextAlign.center,
              ),
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
                      builder: (context) => new ListaQuestoesAluno(
                          turma: turma, aluno: aluno, listPlot: listPlot)),
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
