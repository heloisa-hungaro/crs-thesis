import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import './xmlfuncoes.dart';
import './pagegraficoalunos.dart';

FileXML file = FileXML();

// ---------------------------------------------------------------------------------------------- //

// ESTATISTICAS ALUNOS

class EstatisticasAlunos extends StatefulWidget {
  final email;
  final turma;
  EstatisticasAlunos({this.email, this.turma});

  @override
  State<StatefulWidget> createState() =>
      EstatisticasAlunosState(email: email, turma: turma);
}

class EstatisticasAlunosState extends State<EstatisticasAlunos> {
  String email;
  String turma;
  EstatisticasAlunosState({this.email, this.turma});
  List<Tuple2> _alunos = [];
  String textPage = '';
  List<Tuple2> _listPlot = [];

  @override
  initState() {
    file.getAlunosTurma(turma, email).then((result) {
      setState(() {
        _alunos = result;
        if (_alunos.length == 0) {
          textPage = 'Nenhum aluno identificado respondeu questionários nesta turma';
        } else {
          textPage = 'Selecionar aluno';
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
              itemCount: _alunos.length * 2,
              itemBuilder: (context, int i) {
                if (i.isOdd) {
                  return Divider();
                }
                final int index = i ~/ 2;
                String item = _alunos[index].item2;
                return ListTile(
                  title: Text(item),
                  onTap: () {
                    file
                        .getListPlotAlunoTurma(
                            turma, _alunos[index].item1, email)
                        .then((result) {
                      _listPlot = result;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new GraficoAluno(
                                turma: turma,
                                email: _alunos[index].item1,
                                aluno: _alunos[index].item2,
                                listPlot: _listPlot)),
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
