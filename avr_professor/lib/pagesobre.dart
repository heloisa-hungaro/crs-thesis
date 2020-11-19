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
        title: Text("SOBRE: AvR Professor"),
      ),
      body: Column(children: <Widget>[
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '''
              Avaliação Rápida Módulo Professor é parte de um sistema de respostas em sala de aula: AvR.
              
              Por meio deste aplicativo o professor pode gerar questões para a turma responder através de seus dispositivos móveis pessoais.

              Só há a necessidade de conexão com a internet para realizar login no aplicativo; depois pode ser utilizado sem internet.
			
              É possível verificar estatísticas gerais de desempenho de turmas e alunos que responderam as questões.
              
              Os alunos devem instalar o aplicativo AvR Aluno para responder. Aluno e professor devem estar conectados na mesma rede para utilizar o sistema.
			  
			        Caso o aluno não possua acesso à internet para realizar login no sistema Avr Aluno, pode usar a função anônima. Neste caso, a resposta do aluno é salva sem identificação.''',
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
