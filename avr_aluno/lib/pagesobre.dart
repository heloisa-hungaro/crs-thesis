import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------------------------- //

// SOBRE

class Sobre extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SobreState();
}

class SobreState extends State<Sobre> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text("SOBRE: AvR Aluno"),
      ),
      body: Column(children: <Widget>[
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '''
              Avaliação Rápida Módulo Aluno é parte de um sistema de respostas em sala de aula: AvR.
              
              Por meio deste aplicativo o aluno pode responder questões geradas pelos seus professores utizando um dispositivo móvel.
              
              Só há a necessidade de conexão com a internet para realizar login no aplicativo; depois pode ser utilizado sem internet. Caso o aluno não possua acesso à internet para efetuar o login, pode responder no modo anônimo.
              
              Com login, o aluno pode verificar suas estatísticas gerais de desempenho em cada turma.
              
              O professor deve utilizar o aplicativo AvR Professor para gerar as questões. Aluno e professor devem estar conectados na mesma rede para utilizar o sistema.''',
                style: TextStyle(fontSize: 19, color: Colors.blue[900]),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
