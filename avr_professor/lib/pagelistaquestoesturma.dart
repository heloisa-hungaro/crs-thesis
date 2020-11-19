import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import './xmlfuncoes.dart';
import './pagegraficoalternativas.dart';

FileXML file = FileXML();

// ---------------------------------------------------------------------------------------------- //

// LISTA QUESTOES TURMA

class ListaQuestoesTurma extends StatefulWidget {
  final turma;
  final listPlot;
  final email;
  final contAcertos;
  ListaQuestoesTurma({this.turma, this.listPlot, this.email, this.contAcertos});

  @override
  State<StatefulWidget> createState() => ListaQuestoesTurmaState(
      turma: turma, listPlot: listPlot, email: email, contAcertos: contAcertos);
}

class ListaQuestoesTurmaState extends State<ListaQuestoesTurma> {
  List<Tuple2> listPlot;
  String turma;
  String email;
  List<Tuple2> contAcertos;
  ListaQuestoesTurmaState(
      {this.turma, this.listPlot, this.email, this.contAcertos});

  List<int> listAlternativas;
  List<Tuple2> listAlunos;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("HISTÓRICO"),
      ),
      body: Column(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'Turma: $turma',
            style: TextStyle(fontSize: 20, color: Colors.blue[900]),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'Selecione uma questão para ver o gráfico de barras',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
              padding: const EdgeInsets.all(5.0),
              itemCount: listPlot.length * 2,
              itemBuilder: (context, int i) {
                if (i.isOdd) {
                  return Divider();
                }
                final int index = i ~/ 2;
                String item = "${listPlot[index].item1}";
                String sub =
                    "(${contAcertos[index].item1} acertos de ${contAcertos[index].item2})";
                return Ink(
                  color: Colors.blue[100],
                  child: ListTile(
                      title: Text(item,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(sub,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        file
                            .getListPlotQuestaoTurma(turma, item, email)
                            .then((result) {
                          listAlternativas = result;
                          file.getListAlunosQuestao().then((result) {
                            listAlunos = result;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => new GraficoAlternativas(
                                      turma: turma,
                                      questao: item,
                                      listPlot: listAlternativas,
                                      listAlunos: listAlunos)),
                            );
                          });
                        });
                      }),
                );
              }),
        ),
      ]),
    );
  }
}
