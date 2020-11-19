import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

// ---------------------------------------------------------------------------------------------- //

// LISTA QUESTOES ALUNOS

class ListaQuestoesAluno extends StatefulWidget {
  final turma;
  final aluno;
  final listPlot;
  ListaQuestoesAluno({this.turma, this.aluno, this.listPlot});

  @override
  State<StatefulWidget> createState() =>
      ListaQuestoesAlunoState(turma: turma, aluno: aluno, listPlot: listPlot);
}

class ListaQuestoesAlunoState extends State<ListaQuestoesAluno> {
  List<Tuple2> listPlot;
  String turma;
  String aluno;
  ListaQuestoesAlunoState({this.turma, this.aluno, this.listPlot});

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
            'Aluno: $aluno',
            style: TextStyle(fontSize: 20, color: Colors.blue[900]),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            'Turma: $turma',
            style: TextStyle(fontSize: 20, color: Colors.blue[900]),
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
                String item = listPlot[index].item1;
                var acertou = false;
                if (index == 0) {
                  listPlot[index].item2 == 0 ? acertou = false : acertou = true;
                } else {
                  if (listPlot[index].item2 == 100) {
                    acertou = true;
                  } else {
                    (listPlot[index].item2 > listPlot[index - 1].item2)
                        ? acertou = true
                        : acertou = false;
                  }
                }
                return Ink(
                  color: acertou ? Colors.green[400] : Colors.red[400],
                  child: ListTile(
                      title: Center(
                          child: Text(item,
                              style: TextStyle(fontWeight: FontWeight.bold)))),
                );
              }),
        ),
      ]),
    );
  }
}
