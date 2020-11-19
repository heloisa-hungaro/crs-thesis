import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:fcharts/fcharts.dart';
import './pagelistaquestoes.dart';

// ---------------------------------------------------------------------------------------------- //

// GRAFICO

class Grafico extends StatefulWidget {
  final turma;
  final professor;
  final listPlot;
  final acertos;
  Grafico({this.turma, this.professor, this.listPlot, this.acertos});

  @override
  State<StatefulWidget> createState() => GraficoState(
      turma: turma, professor: professor, listPlot: listPlot, acertos: acertos);
}

class GraficoState extends State<Grafico> {
  String turma;
  String professor;
  List<Tuple2> listPlot;
  String acertos;
  GraficoState({this.turma, this.professor, this.listPlot, this.acertos});
  List<List<String>> myData = [];
  bool grafVazio = false;

  @override
  initState() {
    var count = 1;
    if (listPlot.isEmpty) {
      grafVazio = true;
    } else {
      listPlot.forEach((k) {
        List<String> aux = [];
        aux.add(count.toString());
        aux.add(k.item2.toString());
        myData.add(aux);
        count++;
      });
    }
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
        body: ListView(children: <Widget>[
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
              'Professor: $professor',
              style: TextStyle(fontSize: 20, color: Colors.blue[900]),
              textAlign: TextAlign.center,
            ),
          ),
          grafVazio
              ? Container(
                  padding: const EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 0.0),
                  child: Text(
                    'Questões respondidas ainda não liberadas.\nQuando o professor não enviar a resposta, aguarde 30 minutos após responder para visualização.',
                    style: TextStyle(fontSize: 15, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                  Widget>[
                  Container(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Acertos: $acertos',
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
                            builder: (context) => new ListaQuestoes(
                                turma: turma,
                                professor: professor,
                                listPlot: listPlot)),
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
                            stroke:
                                PaintOptions.stroke(color: Colors.blue[800]),
                            marker: MarkerOptions(
                              paint: PaintOptions.fill(color: Colors.blue[900]),
                              shape: MarkerShapes.circle,
                            ),
                          ),
                        ],
                        chartPadding:
                            new EdgeInsets.fromLTRB(40.0, 30.0, 20.0, 30.0),
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
                  Container(
                    padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                    child: Text(
                      'Obs: Quando o professor não enviar a resposta, aguarde 30 minutos após responder para visualização.',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ]),
        ]));
  }
}
