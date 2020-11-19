import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

// ---------------------------------------------------------------------------------------------- //

// LISTA RESPOSTAS TURMA

class ListaRespostasTurma extends StatefulWidget {
  final turma;
  final listAlunos;
  final questao;
  final correta;
  ListaRespostasTurma(
      {this.turma, this.questao, this.listAlunos, this.correta});

  @override
  State<StatefulWidget> createState() => ListaRespostasTurmaState(
      turma: turma, questao: questao, listAlunos: listAlunos, correta: correta);
}

class ListaRespostasTurmaState extends State<ListaRespostasTurma> {
  List<Tuple2> listAlunos;
  String turma;
  String questao;
  int correta;
  ListaRespostasTurmaState(
      {this.turma, this.questao, this.listAlunos, this.correta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("RESPOSTAS ALUNOS"),
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
            'Questão: $questao',
            style: TextStyle(fontSize: 20, color: Colors.blue[900]),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
              padding: const EdgeInsets.all(5.0),
              itemCount: listAlunos.length * 2,
              itemBuilder: (context, int i) {
                if (i.isOdd) {
                  return Divider();
                }
                final int index = i ~/ 2;
                String item = listAlunos[index].item1;
                String sub = listAlunos[index].item2;
                var acertou = false;
                if (listAlunos[index].item2 ==
                    String.fromCharCode(64 + correta)) {
                  acertou = true;
                }
                return Ink(
                  color: acertou ? Colors.green[400] : Colors.red[400],
                  child: ListTile(
                    title: Text(item,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(sub,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              }),
        ),
      ]),
    );
  }
}
